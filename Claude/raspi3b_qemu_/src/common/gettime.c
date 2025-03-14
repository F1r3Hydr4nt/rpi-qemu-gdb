// /* gettime.c - Wrapper for time functions
//  * Copyright (C) 1998, 2002, 2007, 2011 Free Software Foundation, Inc.
//  *
//  * This file is part of GnuPG.
//  *
//  * This file is free software; you can redistribute it and/or modify
//  * it under the terms of either
//  *
//  *   - the GNU Lesser General Public License as published by the Free
//  *     Software Foundation; either version 3 of the License, or (at
//  *     your option) any later version.
//  *
//  * or
//  *
//  *   - the GNU General Public License as published by the Free
//  *     Software Foundation; either version 2 of the License, or (at
//  *     your option) any later version.
//  *
//  * or both in parallel, as here.
//  *
//  * This file is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see <https://www.gnu.org/licenses/>.
//  */

// #include <config.h>
// #include <stdlib.h>
// #include <time.h>
// #include <ctype.h>
// #ifdef HAVE_LOCALE_H
// #include <locale.h>
// #endif
// #ifdef HAVE_LANGINFO_H
// #include <langinfo.h>
// #endif
// #ifdef HAVE_W32_SYSTEM
// # define WIN32_LEAN_AND_MEAN
// # include <windows.h>
// #endif /*!HAVE_W32_SYSTEM*/
// #include <stdint.h>    /* We use uint64_t.  */

// #include "util.h"
// #include "i18n.h"
// #include "gettime.h"

// #ifdef HAVE_UNSIGNED_TIME_T
// # define IS_INVALID_TIME_T(a) ((a) == (time_t)(-1))
// #else
//   /* Error or 32 bit time_t and value after 2038-01-19.  */
// # define IS_INVALID_TIME_T(a) ((a) < 0)
// #endif


// static unsigned long timewarp;
// static enum { NORMAL = 0, FROZEN, FUTURE, PAST } timemode;

// /* Correction used to map to real Julian days. */
// #define JD_DIFF 1721060L



// /*
//   timegm() is a GNU function that might not be available everywhere.
//   It's basically the inverse of gmtime() - you give it a struct tm,
//   and get back a time_t.  It differs from mktime() in that it handles
//   the case where the struct tm is UTC and the local environment isn't.

//   Note, that this replacement implementation might not be thread-safe!

//   Some BSDs don't handle the putenv("foo") case properly, so we use
//   unsetenv if the platform has it to remove environment variables.
// */
// #ifndef HAVE_TIMEGM
// time_t
// timegm (struct tm *tm)
// {
// #ifdef HAVE_W32_SYSTEM
//   uint64_t val = timegm_u64 (tm);
//   if (val == (uint64_t)(-1))
//     return (time_t)(-1);
//   return (time_t)val;
// #else /* (Non thread safe implementation!) */

//   time_t answer;
//   char *zone;

//   zone=getenv("TZ");
//   putenv("TZ=UTC");
//   tzset();
//   answer=mktime(tm);
//   if(zone)
//     {
//       static char *old_zone;

//       if (!old_zone)
//         {
//           old_zone = malloc(3+strlen(zone)+1);
//           if (old_zone)
//             {
//               strcpy(old_zone,"TZ=");
//               strcat(old_zone,zone);
//             }
// 	}
//       if (old_zone)
//         putenv (old_zone);
//     }
//   else
//     gnupg_unsetenv("TZ");

//   tzset();
//   return answer;
// #endif
// }
// #endif /*!HAVE_TIMEGM*/


// /* Version of the GNU timegm which returns an unsigned 64 bit integer
//  * instead of the usually signed time_t.  On error (uint64_t)(-1) is
//  * returned.  This function is mostly here becuase on 32 bit Windows
//  * we have an internal API to get the system time even after
//  * 2023-01-19.  For 32 bit Unix we need to suffer from the too short
//  * time_t and no system function to construct the time from a tm.  */
// uint64_t
// timegm_u64 (struct tm *tm)
// {
// #ifdef HAVE_W32_SYSTEM
//   /* This one is thread safe.  */
//   SYSTEMTIME st;
//   FILETIME ft;
//   unsigned long long cnsecs;

//   st.wYear   = tm->tm_year + 1900;
//   st.wMonth  = tm->tm_mon  + 1;
//   st.wDay    = tm->tm_mday;
//   st.wHour   = tm->tm_hour;
//   st.wMinute = tm->tm_min;
//   st.wSecond = tm->tm_sec;
//   st.wMilliseconds = 0; /* Not available.  */
//   st.wDayOfWeek = 0;    /* Ignored.  */

//   /* System time is UTC thus the conversion is pretty easy.  */
//   if (!SystemTimeToFileTime (&st, &ft))
//     {
//       gpg_err_set_errno (EINVAL);
//       return (uint64_t)(-1);
//     }

//   cnsecs = (((unsigned long long)ft.dwHighDateTime << 32)
//             | ft.dwLowDateTime);
//   cnsecs -= 116444736000000000ULL; /* The filetime epoch is 1601-01-01.  */
//   return (uint64_t)(cnsecs / 10000000ULL);

// #else /*Unix*/

//   time_t t = timegm (tm);
//   if (t == (time_t)(-1))
//     return (uint64_t)(-1);
//   if ((int64_t)t < 0)
//     return (uint64_t)(-1);
//   return (uint64_t)t;

// #endif /*Unix*/
// }


// /* Wrapper for the time(3).  We use this here so we can fake the time
//    for tests */
// time_t
// gnupg_get_time ()
// {
//   time_t current = time (NULL);
//   if (current == (time_t)(-1))
//     log_fatal ("time() failed\n");

//   if (timemode == NORMAL)
//     return current;
//   else if (timemode == FROZEN)
//     return timewarp;
//   else if (timemode == FUTURE)
//     return current + timewarp;
//   else
//     return current - timewarp;
// }


// /* Wrapper around gmtime_r.

//    On systems without gmtime_r this implementation works within gnupg
//    because we use only one thread a time.  FIXME: An independent
//    library may use gmtime in one of its own thread (or via
//    npth_enter/npth_leave) - in this case we run into a problem.  The
//    solution would be to use a mutex here.  */
// struct tm *
// gnupg_gmtime (const time_t *timep, struct tm *result)
// {
// #ifdef HAVE_GMTIME_R
//   return gmtime_r (timep, result);
// #else
//   struct tm *tp;

//   tp = gmtime (timep);
//   if (tp)
//     memcpy (result, tp, sizeof *result);
//   return tp;
// #endif
// }


// /* Return the current time (possibly faked) in ISO format. */
// void
// gnupg_get_isotime (gnupg_isotime_t timebuf)
// {
//   time_t atime = gnupg_get_time ();
//   struct tm *tp;
//   struct tm tmbuf;

//   tp = gnupg_gmtime (&atime, &tmbuf);
//   if (!tp)
//     *timebuf = 0;
//   else
//     snprintf (timebuf, 16, "%04d%02d%02dT%02d%02d%02d",
//               1900 + tp->tm_year, tp->tm_mon+1, tp->tm_mday,
//               tp->tm_hour, tp->tm_min, tp->tm_sec);
// }


// /* Set the time to NEWTIME so that gnupg_get_time returns a time
//    starting with this one.  With FREEZE set to 1 the returned time
//    will never change.  Just for completeness, a value of (time_t)-1
//    for NEWTIME gets you back to reality.  Note that this is obviously
//    not thread-safe but this is not required. */
// void
// gnupg_set_time (time_t newtime, int freeze)
// {
//   time_t current = time (NULL);

//   if ( newtime == (time_t)-1 || current == newtime)
//     {
//       timemode = NORMAL;
//       timewarp = 0;
//     }
//   else if (freeze)
//     {
//       timemode = FROZEN;
//       timewarp = newtime == (time_t)-1 ? current : newtime;
//     }
//   else if (newtime > current)
//     {
//       timemode = FUTURE;
//       timewarp = newtime - current;
//     }
//   else
//     {
//       timemode = PAST;
//       timewarp = current - newtime;
//     }
// }

// /* Returns true when we are in timewarp mode */
// int
// gnupg_faked_time_p (void)
// {
//   return timemode;
// }


// /* This function is used by gpg because OpenPGP defines the timestamp
//    as an unsigned 32 bit value. */
// u32
// make_timestamp (void)
// {
//   time_t t = gnupg_get_time ();
//   return (u32)t;
// }


// /* Specialized version of atoi which returns an u32 instead of an int
//  * and caps the result at 2^32-2.  Leading white space is skipped,
//  * scanning stops at at the first non-convertable byte.  Note that we
//  * do not cap at 2^32-1 because that value is often used as error
//  * return. */
// u32
// scan_secondsstr (const char *string)
// {
//   uint64_t value = 0;

//   while (*string == ' ' || *string == '\t')
//     string++;
//   for (; *string >= '0' && *string <= '9'; string++)
//     {
//       value *= 10;
//       value += atoi_1 (string);
//       if (value >= (u32)(-1))
//         return (u32)(-1) - 1;
//     }
//   return (u32)value;
// }


// /****************
//  * Scan a date string and return a timestamp.
//  * The only supported format is "yyyy-mm-dd"
//  * Returns 0 for an invalid date.
//  */
// u32
// scan_isodatestr( const char *string )
// {
//     int year, month, day;
//     struct tm tmbuf;
//     time_t stamp;
//     int i;

//     if( strlen(string) != 10 || string[4] != '-' || string[7] != '-' )
// 	return 0;
//     for( i=0; i < 4; i++ )
// 	if( !digitp (string+i) )
// 	    return 0;
//     if( !digitp (string+5) || !digitp(string+6) )
// 	return 0;
//     if( !digitp(string+8) || !digitp(string+9) )
// 	return 0;
//     year = atoi(string);
//     month = atoi(string+5);
//     day = atoi(string+8);
//     /* some basic checks */
//     if( year < 1970 || month < 1 || month > 12 || day < 1 || day > 31 )
// 	return 0;
//     memset( &tmbuf, 0, sizeof tmbuf );
//     tmbuf.tm_mday = day;
//     tmbuf.tm_mon = month-1;
//     tmbuf.tm_year = year - 1900;
//     tmbuf.tm_isdst = -1;
//     stamp = mktime( &tmbuf );
//     if( stamp == (time_t)-1 )
//       {
//         /* mktime did not work.  Construct an ISO timestring for noon
//          * of the given day instead.  We keep the use of mktime for 64
//          * bit system to limit the risk of regressions. */
//         gnupg_isotime_t isobuf;
//         uint64_t tmp64;

//         snprintf (isobuf, 16, "%04d%02d%02dT120000", year, month, day);
//         tmp64 = isotime2epoch_u64 (isobuf);
//         if (tmp64 == (uint64_t)(-1))
//           return 0;  /* Error.  */
//         if (tmp64 >= (u32)(-1))
//           return 0;   /* Error.  */
//         return (u32)tmp64;
//       }
//     return stamp;
// }


// int
// isotime_p (const char *string)
// {
//   const char *s;
//   int i;

//   if (!*string)
//     return 0;
//   for (s=string, i=0; i < 8; i++, s++)
//     if (!digitp (s))
//       return 0;
//   if (*s != 'T')
//       return 0;
//   for (s++, i=9; i < 15; i++, s++)
//     if (!digitp (s))
//       return 0;
//   if (*s == 'Z')
//     s++;
//   if ( !(!*s || (isascii (*s) && isspace(*s)) || *s == ':' || *s == ','))
//     return 0;  /* Wrong delimiter.  */

//   return 1;
// }


// /* Scan a string and return true if the string represents the human
//    readable format of an ISO time.  This format is:
//       yyyy-mm-dd[ hh[:mm[:ss]]]
//    Scanning stops at the second space or at a comma.  If DATE_ONLY is
//    true the time part is not expected and the scanning stops at the
//    first space or at a comma. */
// int
// isotime_human_p (const char *string, int date_only)
// {
//   const char *s;
//   int i;

//   if (!*string)
//     return 0;
//   for (s=string, i=0; i < 4; i++, s++)
//     if (!digitp (s))
//       return 0;
//   if (*s != '-')
//     return 0;
//   s++;
//   if (!digitp (s) || !digitp (s+1) || s[2] != '-')
//     return 0;
//   i = atoi_2 (s);
//   if (i < 1 || i > 12)
//     return 0;
//   s += 3;
//   if (!digitp (s) || !digitp (s+1))
//     return 0;
//   i = atoi_2 (s);
//   if (i < 1 || i > 31)
//     return 0;
//   s += 2;
//   if (!*s || *s == ',')
//     return 1; /* Okay; only date given.  */
//   if (!spacep (s))
//     return 0;
//   if (date_only)
//     return 1; /* Okay; only date was requested.  */
//   s++;
//   if (spacep (s))
//     return 1; /* Okay, second space stops scanning.  */
//   if (!digitp (s) || !digitp (s+1))
//     return 0;
//   i = atoi_2 (s);
//   if (i < 0 || i > 23)
//     return 0;
//   s += 2;
//   if (!*s || *s == ',')
//     return 1; /* Okay; only date and hour given.  */
//   if (*s != ':')
//     return 0;
//   s++;
//   if (!digitp (s) || !digitp (s+1))
//     return 0;
//   i = atoi_2 (s);
//   if (i < 0 || i > 59)
//     return 0;
//   s += 2;
//   if (!*s || *s == ',')
//     return 1; /* Okay; only date, hour and minute given.  */
//   if (*s != ':')
//     return 0;
//   s++;
//   if (!digitp (s) || !digitp (s+1))
//     return 0;
//   i = atoi_2 (s);
//   if (i < 0 || i > 60)
//     return 0;
//   s += 2;
//   if (!*s || *s == ',' || spacep (s))
//     return 1; /* Okay; date, hour and minute and second given.  */

//   return 0; /* Unexpected delimiter.  */
// }

// /* Convert a standard isotime or a human readable variant into an
//    isotime structure.  The allowed formats are those described by
//    isotime_p and isotime_human_p.  The function returns 0 on failure
//    or the length of the scanned string on success.  */
// size_t
// string2isotime (gnupg_isotime_t atime, const char *string)
// {
//   gnupg_isotime_t dummyatime;

//   if (!atime)
//     atime = dummyatime;

//   atime[0] = 0;
//   if (isotime_p (string))
//     {
//       memcpy (atime, string, 15);
//       atime[15] = 0;
//       return 15;
//     }
//   if (!isotime_human_p (string, 0))
//     return 0;
//   atime[0] = string[0];
//   atime[1] = string[1];
//   atime[2] = string[2];
//   atime[3] = string[3];
//   atime[4] = string[5];
//   atime[5] = string[6];
//   atime[6] = string[8];
//   atime[7] = string[9];
//   atime[8] = 'T';
//   memset (atime+9, '0', 6);
//   atime[15] = 0;
//   if (!spacep (string+10))
//     return 10;
//   if (spacep (string+11))
//     return 11; /* As per def, second space stops scanning.  */
//   atime[9] = string[11];
//   atime[10] = string[12];
//   if (string[13] != ':')
//     return 13;
//   atime[11] = string[14];
//   atime[12] = string[15];
//   if (string[16] != ':')
//     return 16;
//   atime[13] = string[17];
//   atime[14] = string[18];
//   return 19;
// }


// /* Helper for isotime2epoch.  Returns 0 on success. */
// static int
// isotime_make_tm (const char *string, struct tm *tmbuf)
// {
//   int year, month, day, hour, minu, sec;

//   if (!isotime_p (string))
//     return -1;

//   year  = atoi_4 (string);
//   month = atoi_2 (string + 4);
//   day   = atoi_2 (string + 6);
//   hour  = atoi_2 (string + 9);
//   minu  = atoi_2 (string + 11);
//   sec   = atoi_2 (string + 13);

//   /* Basic checks.  */
//   if (year < 1970 || month < 1 || month > 12 || day < 1 || day > 31
//       || hour > 23 || minu > 59 || sec > 61 )
//     return -1;

//   memset (tmbuf, 0, sizeof *tmbuf);
//   tmbuf->tm_sec  = sec;
//   tmbuf->tm_min  = minu;
//   tmbuf->tm_hour = hour;
//   tmbuf->tm_mday = day;
//   tmbuf->tm_mon  = month-1;
//   tmbuf->tm_year = year - 1900;
//   tmbuf->tm_isdst = -1;
//   return 0;
// }


// /* Scan an ISO timestamp and return an Epoch based timestamp.  The
//    only supported format is "yyyymmddThhmmss[Z]" delimited by white
//    space, nul, a colon or a comma.  Returns (time_t)(-1) for an
//    invalid string.  */
// time_t
// isotime2epoch (const char *string)
// {
//   struct tm tmbuf;

//   if (isotime_make_tm (string, &tmbuf))
//     return (time_t)(-1);

//   return timegm (&tmbuf);
// }


// uint64_t
// isotime2epoch_u64 (const char *string)
// {
//   struct tm tmbuf;

//   if (isotime_make_tm (string, &tmbuf))
//     return (uint64_t)(-1);

//   return timegm_u64 (&tmbuf);
// }


// /* Convert an Epoch time to an iso time stamp. */
// void
// epoch2isotime (gnupg_isotime_t timebuf, time_t atime)
// {
//   if (atime == (time_t)(-1))
//     *timebuf = 0;
//   else
//     {
//       struct tm *tp;
// #ifdef HAVE_GMTIME_R
//       struct tm tmbuf;

//       tp = gmtime_r (&atime, &tmbuf);
// #else
//       tp = gmtime (&atime);
// #endif
//       snprintf (timebuf, 16, "%04d%02d%02dT%02d%02d%02d",
//                 1900 + tp->tm_year, tp->tm_mon+1, tp->tm_mday,
//                 tp->tm_hour, tp->tm_min, tp->tm_sec);
//     }
// }


// /* Parse a short ISO date string (YYYY-MM-DD) into a TM structure.
//    Returns 0 on success.  */
// int
// isodate_human_to_tm (const char *string, struct tm *t)
// {
//   int year, month, day;

//   if (!isotime_human_p (string, 1))
//     return -1;

//   year  = atoi_4 (string);
//   month = atoi_2 (string + 5);
//   day   = atoi_2 (string + 8);

//   /* Basic checks.  */
//   if (year < 1970 || month < 1 || month > 12 || day < 1 || day > 31)
//     return -1;

//   memset (t, 0, sizeof *t);
//   t->tm_sec  = 0;
//   t->tm_min  = 0;
//   t->tm_hour = 0;
//   t->tm_mday = day;
//   t->tm_mon  = month-1;
//   t->tm_year = year - 1900;
//   t->tm_isdst = -1;
//   return 0;
// }


// /* Parse the string TIMESTAMP into a time_t.  The string may either be
//    seconds since Epoch or in the ISO 8601 format like
//    "20390815T143012".  Returns 0 for an empty string or seconds since
//    Epoch. Leading spaces are skipped. If ENDP is not NULL, it will
//    point to the next non-parsed character in TIMESTRING.

//    This function is a copy of
//    gpgme/src/conversion.c:_gpgme_parse_timestamp.  If you change it,
//    then update the other one too.

//    FIXME: Replace users of this function by one of the more modern
//           functions or change the return type to u64.
// */
// time_t
// parse_timestamp (const char *timestamp, char **endp)
// {
//   /* Need to skip leading spaces, because that is what strtoul does
//      but not our ISO 8601 checking code. */
//   while (*timestamp && *timestamp== ' ')
//     timestamp++;
//   if (!*timestamp)
//     return 0;

//   if (strlen (timestamp) >= 15 && timestamp[8] == 'T')
//     {
//       struct tm buf;
//       int year;

//       year = atoi_4 (timestamp);
//       if (year < 1900)
//         return (time_t)(-1);

//       if (endp)
//         *endp = (char*)(timestamp + 15);

//       /* Fixme: We would better use a configure test to see whether
//          mktime can handle dates beyond 2038. */
//       if (sizeof (time_t) <= 4 && year >= 2038)
//         return (time_t)2145914603; /* 2037-12-31 23:23:23 */

//       memset (&buf, 0, sizeof buf);
//       buf.tm_year = year - 1900;
//       buf.tm_mon = atoi_2 (timestamp+4) - 1;
//       buf.tm_mday = atoi_2 (timestamp+6);
//       buf.tm_hour = atoi_2 (timestamp+9);
//       buf.tm_min = atoi_2 (timestamp+11);
//       buf.tm_sec = atoi_2 (timestamp+13);

//       return timegm (&buf);
//     }
//   else
//     return (time_t)strtoul (timestamp, endp, 10);
// }



// u32
// add_days_to_timestamp( u32 stamp, u16 days )
// {
//     return stamp + days*86400L;
// }


// /****************
//  * Return a string with a time value in the form: x Y, n D, n H
//  */

// const char *
// strtimevalue( u32 value )
// {
//     static char buffer[30];
//     unsigned int years, days, hours, minutes;

//     value /= 60;
//     minutes = value % 60;
//     value /= 60;
//     hours = value % 24;
//     value /= 24;
//     days = value % 365;
//     value /= 365;
//     years = value;

//     sprintf(buffer,"%uy%ud%uh%um", years, days, hours, minutes );
//     if( years )
// 	return buffer;
//     if( days )
// 	return strchr( buffer, 'y' ) + 1;
//     return strchr( buffer, 'd' ) + 1;
// }



// /* Return a malloced string with the time elapsed between NOW and
//    SINCE.  May return NULL on error. */
// char *
// elapsed_time_string (time_t since, time_t now)
// {
//   char *result;
//   double diff;
//   unsigned long value;
//   unsigned int days, hours, minutes, seconds;

//   if (!now)
//     now = gnupg_get_time ();

//   diff = difftime (now, since);
//   if (diff < 0)
//     return xtrystrdup ("time-warp");

//   seconds = (unsigned long)diff % 60;
//   value = (unsigned long)(diff / 60);
//   minutes = value % 60;
//   value /= 60;
//   hours = value % 24;
//   value /= 24;
//   days = value % 365;

//   if (days)
//     result = xtryasprintf ("%ud%uh%um%us", days, hours, minutes, seconds);
//   else if (hours)
//     result = xtryasprintf ("%uh%um%us", hours, minutes, seconds);
//   else if (minutes)
//     result = xtryasprintf ("%um%us", minutes, seconds);
//   else
//     result = xtryasprintf ("%us", seconds);

//   return result;
// }


// /*
//  * Note: this function returns GMT
//  */
// const char *
// strtimestamp (u32 stamp)
// {
//   static char buffer[11+5];
//   struct tm *tp;
//   time_t atime = stamp;

//   if (IS_INVALID_TIME_T (atime))
//     {
//       strcpy (buffer, "????" "-??" "-??");
//     }
//   else
//     {
//       tp = gmtime( &atime );
//       snprintf (buffer, sizeof buffer, "%04d-%02d-%02d",
//                 1900+tp->tm_year, tp->tm_mon+1, tp->tm_mday );
//     }
//   return buffer;
// }


// /*
//  * Note: this function returns GMT
//  */
// const char *
// isotimestamp (u32 stamp)
// {
//   static char buffer[25+5];
//   struct tm *tp;
//   time_t atime = stamp;

//   if (IS_INVALID_TIME_T (atime))
//     {
//       strcpy (buffer, "????" "-??" "-??" " " "??" ":" "??" ":" "??");
//     }
//   else
//     {
//       tp = gmtime ( &atime );
//       snprintf (buffer, sizeof buffer, "%04d-%02d-%02d %02d:%02d:%02d",
//                 1900+tp->tm_year, tp->tm_mon+1, tp->tm_mday,
//                 tp->tm_hour, tp->tm_min, tp->tm_sec);
//     }
//   return buffer;
// }


// /* Windows version of strftime returning the string as utf-8.  */
// #ifdef HAVE_W32_SYSTEM

// #define strftime(a,b,c,d)  w32_strftime ((a),(b),(c),(d))

// static size_t
// w32_strftime (char *s, size_t max, const char *format, const struct tm *tm)
// {
//   wchar_t *wformatbuf = NULL;
//   const wchar_t *wformat = L"%c %Z";
//   wchar_t wbuf[200];
//   size_t n;
//   char *buf;

//   if (strcmp (format, "%c %Z"))
//     {
//       log_debug ("  comverted\n");
//       wformatbuf = utf8_to_wchar (format);
//       if (wformatbuf)
//         wformat = wformatbuf;
//     }

//   n = wcsftime (wbuf, sizeof wbuf, wformat, tm);
//   xfree (wformatbuf);
//   if (!n)
//     {
//       /* Most likely the buffer is too short - try ISO format instead.  */
//       n = wcsftime (wbuf, sizeof wbuf, L"%Y-%m-%d %H:%M:%S", tm);
//       if (!n)
//         wcscpy (wbuf, L"[????" "-??" "-??]");
//     }
//   buf = wchar_to_utf8 (wbuf);
//   mem2str (s, buf? buf : "[????" "-??" "-??]", max);
//   xfree (buf);
//   return strlen (s) + 1;
// }
// #endif /*HAVE_W32_SYSTEM*/



// /****************
//  * Note: this function returns local time
//  */
// const char *
// asctimestamp (u32 stamp)
// {
//   static char buffer[80];
// #if defined (HAVE_STRFTIME) && defined (HAVE_NL_LANGINFO)
//   static char fmt[80];
// #endif
//   struct tm *tp;
//   time_t atime = stamp;

//   if (IS_INVALID_TIME_T (atime))
//     {
//       strcpy (buffer, "????" "-??" "-??");
//       return buffer;
//     }
//   tp = localtime( &atime );
// #ifdef HAVE_STRFTIME
// # if defined(HAVE_NL_LANGINFO)
//   mem2str( fmt, nl_langinfo(D_T_FMT), DIM(fmt)-3 );
//   if (!strstr( fmt, "%Z" ))
//     strcat( fmt, " %Z");
//   /* NOTE: gcc -Wformat-noliteral will complain here.  I have found no
//      way to suppress this warning.  */
//   strftime (buffer, DIM(buffer)-1, fmt, tp);
// # elif defined(HAVE_W32CE_SYSTEM)
//   /* tzset is not available but %Z nevertheless prints a default
//      nonsense timezone ("WILDABBR").  Thus we don't print the time
//      zone at all.  */
//   strftime (buffer, DIM(buffer)-1, "%c", tp);
// # else
// #  if HAVE_W32_SYSTEM
//   {
//     static int done;

//     if (!done)
//       {
//         /* The locale names as used by Windows are in the form
//          * "German_Germany.1252" or "German_Austria.1252" with
//          * alternate names similar to Unix, e.g. "de-DE".  However
//          * that is the theory.  On current Windows and Mingw the
//          * alternate names do not work.  We would need a table to map
//          * them from the short names as provided by gpgrt to the long
//          * names and append some code page.  For now we use "" and
//          * take the locale from the user's system settings.  Thus the
//          * standard Unix envvars don't work for time and may mismatch
//          * with the string translations.  The new UCRT available since
//          * 2018 has a lot of additional support but that will for sure
//          * break other things.  We should move to ISO strings to get
//          * rid of such problems.  */
//         setlocale (LC_TIME, ".UTF8");
//         done = 1;
//         /* log_debug ("LC_ALL  now '%s'\n", setlocale (LC_ALL, NULL)); */
//         /* log_debug ("LC_TIME now '%s'\n", setlocale (LC_TIME, NULL)); */
//       }
//   }
// #  endif
//    /* FIXME: we should check whether the locale appends a " %Z" These
//     * locales from glibc don't put the " %Z": fi_FI hr_HR ja_JP lt_LT
//     * lv_LV POSIX ru_RU ru_SU sv_FI sv_SE zh_CN.  */
//   strftime (buffer, DIM(buffer)-1, "%c %Z", tp);
// # endif
//   buffer[DIM(buffer)-1] = 0;
// #else
//   mem2str( buffer, asctime(tp), DIM(buffer) );
// #endif
//   return buffer;
// }


// /* Return the timestamp STAMP in RFC-2822 format.  This is always done
//  * in the C locale.  We return the gmtime to avoid computing the
//  * timezone. The caller must release the returned string.
//  *
//  * Example: "Mon, 27 Jun 2016 1:42:00 +0000".
//  */
// char *
// rfctimestamp (u32 stamp)
// {
//   time_t atime = stamp;
//   struct tm tmbuf, *tp;


//   if (IS_INVALID_TIME_T (atime))
//     {
//       // gpg_err_set_errno (EINVAL);
//       return NULL;
//     }

//   tp = gnupg_gmtime (&atime, &tmbuf);
//   if (!tp)
//     return NULL;
//   return xtryasprintf ("%.3s, %02d %.3s %04d %02d:%02d:%02d +0000",
//                        &"SunMonTueWedThuFriSat"[(tp->tm_wday%7)*3],
//                        tp->tm_mday,
//                        &"JanFebMarAprMayJunJulAugSepOctNovDec"
//                        [(tp->tm_mon%12)*3],
//                        tp->tm_year + 1900,
//                        tp->tm_hour,
//                        tp->tm_min,
//                        tp->tm_sec);
// }


// static int
// days_per_year (int y)
// {
//   int s ;

//   s = !(y % 4);
//   if ( !(y % 100))
//     if ((y%400))
//       s = 0;
//   return s ? 366 : 365;
// }

// static int
// days_per_month (int y, int m)
// {
//   int s;

//   switch(m)
//     {
//     case 1: case 3: case 5: case 7: case 8: case 10: case 12:
//       return 31 ;
//     case 2:
//       s = !(y % 4);
//       if (!(y % 100))
//         if ((y % 400))
//           s = 0;
//       return s? 29 : 28 ;
//     case 4: case 6: case 9: case 11:
//       return 30;
//     }
//   BUG();
// }


// /* Convert YEAR, MONTH and DAY into the Julian date.  We assume that
//    it is already noon.  We do not support dates before 1582-10-15. */
// static unsigned long
// date2jd (int year, int month, int day)
// {
//   unsigned long jd;

//   jd = 365L * year + 31 * (month-1) + day + JD_DIFF;
//   if (month < 3)
//     year-- ;
//   else
//     jd -= (4 * month + 23) / 10;

//   jd += year / 4 - ((year / 100 + 1) *3) / 4;

//   return jd ;
// }

// /* Convert a Julian date back to YEAR, MONTH and DAY.  Return day of
//    the year or 0 on error.  This function uses some more or less
//    arbitrary limits, most important is that days before 1582 are not
//    supported. */
// static int
// jd2date (unsigned long jd, int *year, int *month, int *day)
// {
//   int y, m, d;
//   long delta;

//   if (!jd)
//     return 0 ;
//   if (jd < 1721425 || jd > 2843085)
//     return 0;

//   y = (jd - JD_DIFF) / 366;
//   d = m = 1;

//   while ((delta = jd - date2jd (y, m, d)) > days_per_year (y))
//     y++;

//   m = (delta / 31) + 1;
//   while( (delta = jd - date2jd (y, m, d)) > days_per_month (y,m))
//     if (++m > 12)
//       {
//         m = 1;
//         y++;
//       }

//   d = delta + 1 ;
//   if (d > days_per_month (y, m))
//     {
//       d = 1;
//       m++;
//     }
//   if (m > 12)
//     {
//       m = 1;
//       y++;
//     }

//   if (year)
//     *year = y;
//   if (month)
//     *month = m;
//   if (day)
//     *day = d ;

//   return (jd - date2jd (y, 1, 1)) + 1;
// }


// /* Check that the 15 bytes in ATIME represent a valid ISO time.  Note
//    that this function does not expect a string but a plain 15 byte
//    isotime buffer. */
// gpg_error_t
// check_isotime (const gnupg_isotime_t atime)
// {
//   int i;
//   const char *s;

//   if (!*atime)
//     return gpg_error (GPG_ERR_NO_VALUE);

//   for (s=atime, i=0; i < 8; i++, s++)
//     if (!digitp (s))
//       return gpg_error (GPG_ERR_INV_TIME);
//   if (*s != 'T')
//       return gpg_error (GPG_ERR_INV_TIME);
//   for (s++, i=9; i < 15; i++, s++)
//     if (!digitp (s))
//       return gpg_error (GPG_ERR_INV_TIME);
//   return 0;
// }


// /* Dump the ISO time T to the log stream without a LF.  */
// void
// dump_isotime (const gnupg_isotime_t t)
// {
//   if (!t || !*t)
//     log_printf ("%s", _("[none]"));
//   else
//     log_printf ("%.4s-%.2s-%.2s %.2s:%.2s:%s",
//                 t, t+4, t+6, t+9, t+11, t+13);
// }


// /* Copy one ISO date to another, this is inline so that we can do a
//    minimal sanity check.  A null date (empty string) is allowed.  */
// void
// gnupg_copy_time (gnupg_isotime_t d, const gnupg_isotime_t s)
// {
//   if (*s)
//     {
//       if ((strlen (s) != 15 || s[8] != 'T'))
//         BUG();
//       memcpy (d, s, 15);
//       d[15] = 0;
//     }
//   else
//     *d = 0;
// }


// /* Add SECONDS to ATIME.  SECONDS may not be negative and is limited
//    to about the equivalent of 62 years which should be more then
//    enough for our purposes. */
// gpg_error_t
// add_seconds_to_isotime (gnupg_isotime_t atime, int nseconds)
// {
//   gpg_error_t err;
//   int year, month, day, hour, minute, sec, ndays;
//   unsigned long jd;

//   err = check_isotime (atime);
//   if (err)
//     return err;

//   if (nseconds < 0 || nseconds >= (0x7fffffff - 61) )
//     return gpg_error (GPG_ERR_INV_VALUE);

//   year  = atoi_4 (atime+0);
//   month = atoi_2 (atime+4);
//   day   = atoi_2 (atime+6);
//   hour  = atoi_2 (atime+9);
//   minute= atoi_2 (atime+11);
//   sec   = atoi_2 (atime+13);

//   if (year <= 1582) /* The julian date functions don't support this. */
//     return gpg_error (GPG_ERR_INV_VALUE);

//   sec    += nseconds;
//   minute += sec/60;
//   sec    %= 60;
//   hour   += minute/60;
//   minute %= 60;
//   ndays  = hour/24;
//   hour   %= 24;

//   jd = date2jd (year, month, day) + ndays;
//   jd2date (jd, &year, &month, &day);

//   if (year > 9999 || month > 12 || day > 31
//       || year < 0 || month < 1 || day < 1)
//     return gpg_error (GPG_ERR_INV_VALUE);

//   snprintf (atime, 16, "%04d%02d%02dT%02d%02d%02d",
//             year, month, day, hour, minute, sec);
//   return 0;
// }


// gpg_error_t
// add_days_to_isotime (gnupg_isotime_t atime, int ndays)
// {
//   gpg_error_t err;
//   int year, month, day, hour, minute, sec;
//   unsigned long jd;

//   err = check_isotime (atime);
//   if (err)
//     return err;

//   if (ndays < 0 || ndays >= 9999*366 )
//     return gpg_error (GPG_ERR_INV_VALUE);

//   year  = atoi_4 (atime+0);
//   month = atoi_2 (atime+4);
//   day   = atoi_2 (atime+6);
//   hour  = atoi_2 (atime+9);
//   minute= atoi_2 (atime+11);
//   sec   = atoi_2 (atime+13);

//   if (year <= 1582) /* The julian date functions don't support this. */
//     return gpg_error (GPG_ERR_INV_VALUE);

//   jd = date2jd (year, month, day) + ndays;
//   jd2date (jd, &year, &month, &day);

//   if (year > 9999 || month > 12 || day > 31
//       || year < 0 || month < 1 || day < 1)
//     return gpg_error (GPG_ERR_INV_VALUE);

//   snprintf (atime, 16, "%04d%02d%02dT%02d%02d%02d",
//             year, month, day, hour, minute, sec);
//   return 0;
// }
