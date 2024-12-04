/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */


#ifndef GNUPG_CONFIG_H_INCLUDED
#define GNUPG_CONFIG_H_INCLUDED


/* Agent s2k calibration time (ms) */
#define AGENT_S2K_CALIBRATION 100

/* Defined if the host has big endian byte ordering */
/* #undef BIG_ENDIAN_HOST */

/* an Apple OSXism */
/* #undef BIND_8_COMPAT */

/* GIT commit id revision used to build this package */
#define BUILD_REVISION "398cbbbf8"

/* The time this package was configured for a build */
#define BUILD_TIMESTAMP "<none>"

/* Defined if GPG-AGENT is to be build */
#define BUILD_WITH_AGENT 1

/* Defined if DIRMNGR is to be build */
#define BUILD_WITH_DIRMNGR 1

/* Defined if G13 is to be build */
/* #undef BUILD_WITH_G13 */

/* Defined if GPG is to be build */
#define BUILD_WITH_GPG 1

/* Defined if GPGSM is to be build */
#define BUILD_WITH_GPGSM 1

/* Defined if SCDAEMON is to be build */
#define BUILD_WITH_SCDAEMON 1

/* Use as default system trust store file */
/* #undef DEFAULT_TRUST_STORE_FILE */

/* The default keyserver for dirmngr to use, if none is explicitly given */
#define DIRMNGR_DEFAULT_KEYSERVER "hkps://keyserver.ubuntu.com"

/* The displayed name of dirmngr */
#define DIRMNGR_DISP_NAME "DirMngr"

/* The name of the dirmngr info envvar */
#define DIRMNGR_INFO_NAME "DIRMNGR_INFO"

/* The name of the dirmngr */
#define DIRMNGR_NAME "dirmngr"

/* The name of the dirmngr socket */
#define DIRMNGR_SOCK_NAME "S.dirmngr"

/* define to disable photo viewing */
/* #undef DISABLE_PHOTO_VIEWER */

/* Define to include smartcard support */
#define ENABLE_CARD_SUPPORT 1

/* This is only used with "make distcheck" */
/* #undef ENABLE_GNUPG_BUILDDIR_ENVVAR */

/* Define to 1 if translation of program messages to the user's native
   language is requested. */
#define ENABLE_NLS 1

/* Define to enable SELinux support */
/* #undef ENABLE_SELINUX_HACKS */

/* defines the filename of the encfs program */
#define ENCFS "/usr/bin/encfs"

/* The executable file extension, if any */
#define EXEEXT ""

/* if set, restrict photo-viewer to this */
/* #undef FIXED_PHOTO_VIEWER */

/* defines the filename of the fusermount program */
#define FUSERMOUNT "/usr/bin/fusermount"

/* The displayed name of g13 */
#define G13_DISP_NAME "G13"

/* The name of the g13 tool */
#define G13_NAME "g13"

/* version of the libassuan library */
#define GNUPG_LIBASSUAN_VERSION ""

/* The name of the project */
#define GNUPG_NAME "GnuPG"

/* The directory part of the W32 registry keys */
/* #undef GNUPG_REGISTRY_DIR */

/* swdb tag for this branch */
#define GNUPG_SWDB_TAG "gnupg22"

/* The displayed name of gpgconf */
#define GPGCONF_DISP_NAME "GPGConf"

/* The name of the gpgconf tool */
#define GPGCONF_NAME "gpgconf"

/* The standard binary file suffix */
#define GPGEXT_GPG "gpg"

/* The displayed name of gpgsm */
#define GPGSM_DISP_NAME "GPGSM"

/* The name of the S/MIME tool */
#define GPGSM_NAME "gpgsm"

/* The name of the gpgtar tool */
#define GPGTAR_NAME "gpgtar"

/* The name of the agent socket for browsers */
#define GPG_AGENT_BROWSER_SOCK_NAME "S.gpg-agent.browser"

/* The displayed name of gpg-agent */
#define GPG_AGENT_DISP_NAME "GPG Agent"

/* The name of the agent socket for remote access */
#define GPG_AGENT_EXTRA_SOCK_NAME "S.gpg-agent.extra"

/* The name of the agent */
#define GPG_AGENT_NAME "gpg-agent"

/* The name of the agent socket */
#define GPG_AGENT_SOCK_NAME "S.gpg-agent"

/* The name of the agent socket for ssh */
#define GPG_AGENT_SSH_SOCK_NAME "S.gpg-agent.ssh"

/* The displayed name of gpg */
#define GPG_DISP_NAME "GnuPG"

/* The name of the OpenPGP tool */
#define GPG_NAME "gpg"

/* Define to support the AES128 cipher */
#define GPG_USE_AES128 1

/* Define to support the AES192 cipher */
#define GPG_USE_AES192 1

/* Define to support the AES256 cipher */
#define GPG_USE_AES256 1

/* Define to support the BLOWFISH cipher */
#define GPG_USE_BLOWFISH 1

/* Define to support the CAMELLIA128 cipher */
#define GPG_USE_CAMELLIA128 1

/* Define to support the CAMELLIA192 cipher */
#define GPG_USE_CAMELLIA192 1

/* Define to support the CAMELLIA256 cipher */
#define GPG_USE_CAMELLIA256 1

/* Define to support the CAST5 cipher */
#define GPG_USE_CAST5 1

/* Define to support the ECDH public key */
#define GPG_USE_ECDH 1

/* Define to support the ECDSA public key */
#define GPG_USE_ECDSA 1

/* Define to support the EdDSA public key */
#define GPG_USE_EDDSA 1

/* Define to support the IDEA cipher */
#define GPG_USE_IDEA 1

/* Define to support the MD5 hash */
#define GPG_USE_MD5 1

/* Define to support the RIPE-MD160 hash */
#define GPG_USE_RMD160 1

/* Define to support the RSA public key */
#define GPG_USE_RSA 1

/* Define to support the SHA-224 hash */
#define GPG_USE_SHA224 1

/* Define to support the SHA-384 hash */
#define GPG_USE_SHA384 1

/* Define to support the SHA-512 hash */
#define GPG_USE_SHA512 1

/* Define to support the TWOFISH cipher */
#define GPG_USE_TWOFISH 1

/* Defined if we build for an Android system */
/* #undef HAVE_ANDROID_SYSTEM */

/* Define to 1 if you have the `atexit' function. */
#define HAVE_ATEXIT 1

/* Defined if ttyname does not work properly */
/* #undef HAVE_BROKEN_TTYNAME */

/* Define to 1 if the system has the type `byte'. */
/* #undef HAVE_BYTE */

/* Defined if the bz2 compression library is available */
/* #undef HAVE_BZIP2 */

/* Define to 1 if you have the `canonicalize_file_name' function. */
#define HAVE_CANONICALIZE_FILE_NAME 1

/* Define to 1 if you have the Mac OS X function
   CFLocaleCopyPreferredLanguages in the CoreFoundation framework. */
/* #undef HAVE_CFLOCALECOPYPREFERREDLANGUAGES */

/* Define to 1 if you have the Mac OS X function CFPreferencesCopyAppValue in
   the CoreFoundation framework. */
/* #undef HAVE_CFPREFERENCESCOPYAPPVALUE */

/* Define to 1 if you have the `clock_gettime' function. */
#define HAVE_CLOCK_GETTIME 1

/* Define to 1 if you have the `ctermid' function. */
#define HAVE_CTERMID 1

/* Define if the GNU dcgettext() function is already present or preinstalled.
   */
#define HAVE_DCGETTEXT 1

/* Define to 1 if you have the declaration of `getpagesize', and to 0 if you
   don't. */
#define HAVE_DECL_GETPAGESIZE 1

/* Define to 1 if you have the declaration of `sys_siglist', and to 0 if you
   don't. */
#define HAVE_DECL_SYS_SIGLIST 0

/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
/* #undef HAVE_DOPRNT */

/* Defined if we run on some of the PCDOS like systems (DOS, Windoze. OS/2)
   with special properties like no file modes, case insensitive file names and
   preferred use of backslashes as directory name separators. */
/* #undef HAVE_DOSISH_SYSTEM */

/* Defined if the OS supports drive letters. */
/* #undef HAVE_DRIVE_LETTERS */

/* Define to 1 if you have the `explicit_bzero' function. */
#define HAVE_EXPLICIT_BZERO 1

/* Define to 1 if you have the `fcntl' function. */
#define HAVE_FCNTL 1

/* Define to 1 if you have the `flockfile' function. */
#define HAVE_FLOCKFILE 1

/* Define to 1 if you have the `fork' function. */
#define HAVE_FORK 1

/* Define to 1 if fseeko (and presumably ftello) exists and is declared. */
#define HAVE_FSEEKO 1

/* Define to 1 if you have the `fsync' function. */
#define HAVE_FSYNC 1

/* Define to 1 if you have the `ftello' function. */
#define HAVE_FTELLO 1

/* Define to 1 if you have the `ftruncate' function. */
#define HAVE_FTRUNCATE 1

/* Define to 1 if you have the `funlockfile' function. */
#define HAVE_FUNLOCKFILE 1

/* Define to 1 if you have the `getaddrinfo' function. */
#define HAVE_GETADDRINFO 1

/* Define to 1 if you have the `getenv' function. */
#define HAVE_GETENV 1

/* Define to 1 if you have the `getpagesize' function. */
#define HAVE_GETPAGESIZE 1

/* Define to 1 if you have the `getpeerucred' function. */
/* #undef HAVE_GETPEERUCRED */

/* Define to 1 if you have the `getpwnam' function. */
#define HAVE_GETPWNAM 1

/* Define to 1 if you have the `getpwuid' function. */
#define HAVE_GETPWUID 1

/* Define to 1 if you have the `getrlimit' function. */
#define HAVE_GETRLIMIT 1

/* Define to 1 if you have the `getrusage' function. */
#define HAVE_GETRUSAGE 1

/* Define if the GNU gettext() function is already present or preinstalled. */
#define HAVE_GETTEXT 1

/* Define to 1 if you have the `gettimeofday' function. */
#define HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have the `gmtime_r' function. */
#define HAVE_GMTIME_R 1

/* Define if you have the iconv() function and it works. */
#define HAVE_ICONV 1

/* Define to 1 if you have the `inet_ntop' function. */
#define HAVE_INET_NTOP 1

/* Define to 1 if you have the `inet_pton' function. */
#define HAVE_INET_PTON 1

/* Define to 1 if you have the `inotify_init' function. */
#define HAVE_INOTIFY_INIT 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `isascii' function. */
#define HAVE_ISASCII 1

/* Define if you have <langinfo.h> and nl_langinfo(CODESET). */
#define HAVE_LANGINFO_CODESET 1

/* Define to 1 if you have the <langinfo.h> header file. */
#define HAVE_LANGINFO_H 1

/* defined if liblber is available */
/* #undef HAVE_LBER */

/* Define if your <locale.h> file defines LC_MESSAGES. */
#define HAVE_LC_MESSAGES 1

/* Define to 1 if you have the `ldap_get_option' function. */
/* #undef HAVE_LDAP_GET_OPTION */

/* Define if the LDAP library supports ld_errno */
/* #undef HAVE_LDAP_LD_ERRNO */

/* Define to 1 if you have the `ldap_set_option' function. */
/* #undef HAVE_LDAP_SET_OPTION */

/* Define to 1 if you have the `ldap_start_tls_s' function. */
/* #undef HAVE_LDAP_START_TLS_S */

/* Define to 1 if you have the `ldap_start_tls_sA' function. */
/* #undef HAVE_LDAP_START_TLS_SA */

/* Define to 1 if you have a fully functional readline library. */
/* #undef HAVE_LIBREADLINE */

/* defined if libusb is available */
#define HAVE_LIBUSB 1

/* defined if libutil is available */
#define HAVE_LIBUTIL 1

/* Define to 1 if you have the <locale.h> header file. */
#define HAVE_LOCALE_H 1

/* Define to 1 if you have the `lstat' function. */
#define HAVE_LSTAT 1

/* Define to 1 if you have the `memicmp' function. */
/* #undef HAVE_MEMICMP */

/* Define to 1 if you have the `memmove' function. */
#define HAVE_MEMMOVE 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the `memrchr' function. */
#define HAVE_MEMRCHR 1

/* Define to 1 if you have the `mmap' function. */
#define HAVE_MMAP 1

/* Define to 1 if you have the `nanosleep' function in libc. */
#define HAVE_NANOSLEEP 1

/* Define to 1 if you have the `nl_langinfo' function. */
#define HAVE_NL_LANGINFO 1

/* Defined if the New Portable Thread Library is available */
#define HAVE_NPTH 1

/* Define to 1 if you have the `pipe' function. */
#define HAVE_PIPE 1

/* Defined if we run on systems like NetBSD, where pselect cannot be unblocked
   by signal from a thread within the same process. We use pipe in this case,
   instead. */
#define HAVE_PSELECT_NO_EINTR 1

/* Define to 1 if you have the <pwd.h> header file. */
#define HAVE_PWD_H 1

/* Define to 1 if you have the `raise' function. */
#define HAVE_RAISE 1

/* Define to 1 if you have the `rand' function. */
#define HAVE_RAND 1

/* Define to 1 if you have the `setenv' function. */
#define HAVE_SETENV 1

/* Define to 1 if you have the `setlocale' function. */
#define HAVE_SETLOCALE 1

/* Define to 1 if you have the `setrlimit' function. */
#define HAVE_SETRLIMIT 1

/* Define to 1 if you have the `sigaction' function. */
#define HAVE_SIGACTION 1

/* Define to 1 if you have the `sigdescr_np' function. */
#define HAVE_SIGDESCR_NP 1

/* Define to 1 if you have the <signal.h> header file. */
#define HAVE_SIGNAL_H 1

/* Define to 1 if you have the `sigprocmask' function. */
#define HAVE_SIGPROCMASK 1

/* Define to 1 if the system has the type `sigset_t'. */
#define HAVE_SIGSET_T 1

/* Define to 1 if you have the `stat' function. */
#define HAVE_STAT 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the `stpcpy' function. */
#define HAVE_STPCPY 1

/* Define to 1 if you have the `strcasecmp' function. */
#define HAVE_STRCASECMP 1

/* Define to 1 if you have the `strchr' function. */
#define HAVE_STRCHR 1

/* Define to 1 if you have the `strerror' function. */
#define HAVE_STRERROR 1

/* Define to 1 if you have the `strftime' function. */
#define HAVE_STRFTIME 1

/* Define to 1 if you have the `stricmp' function. */
/* #undef HAVE_STRICMP */

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the `strlwr' function. */
/* #undef HAVE_STRLWR */

/* Define to 1 if you have the `strncasecmp' function. */
#define HAVE_STRNCASECMP 1

/* Define to 1 if you have the `strpbrk' function. */
#define HAVE_STRPBRK 1

/* Define to 1 if you have the `strsep' function. */
#define HAVE_STRSEP 1

/* Define to 1 if you have the `strtol' function. */
#define HAVE_STRTOL 1

/* Define to 1 if you have the `strtoul' function. */
#define HAVE_STRTOUL 1

/* Define to 1 if you have the `strtoull' function. */
#define HAVE_STRTOULL 1

/* Define to 1 if the system has the type `struct sigaction'. */
#define HAVE_STRUCT_SIGACTION 1

/* Define to 1 if `pid' is a member of `struct sockpeercred'. */
/* #undef HAVE_STRUCT_SOCKPEERCRED_PID */

/* Define to 1 if `cr_pid' is a member of `struct ucred'. */
/* #undef HAVE_STRUCT_UCRED_CR_PID */

/* Define to 1 if `pid' is a member of `struct ucred'. */
#define HAVE_STRUCT_UCRED_PID 1

/* The system's resolver is usable. */
#define HAVE_SYSTEM_RESOLVER 1

/* Define to 1 if you have the <sys/mkdev.h> header file. */
/* #undef HAVE_SYS_MKDEV_H */

/* Define to 1 if you have the <sys/select.h> header file. */
#define HAVE_SYS_SELECT_H 1

/* Define to 1 if you have the <sys/socket.h> header file. */
#define HAVE_SYS_SOCKET_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/sysmacros.h> header file. */
#define HAVE_SYS_SYSMACROS_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/ucred.h> header file. */
/* #undef HAVE_SYS_UCRED_H */

/* Define to 1 if you have the `tcgetattr' function. */
#define HAVE_TCGETATTR 1

/* Define to 1 if you have the <termios.h> header file. */
#define HAVE_TERMIOS_H 1

/* Define to 1 if you have the <termio.h> header file. */
#define HAVE_TERMIO_H 1

/* Define to 1 if you have the `timegm' function. */
#define HAVE_TIMEGM 1

/* Define to 1 if you have the `times' function. */
#define HAVE_TIMES 1

/* Define to 1 if you have the `ttyname' function. */
#define HAVE_TTYNAME 1

/* Define to 1 if the system has the type `u16'. */
/* #undef HAVE_U16 */

/* Define to 1 if the system has the type `u32'. */
/* #undef HAVE_U32 */

/* Define to 1 if you have the <ucred.h> header file. */
/* #undef HAVE_UCRED_H */

/* Define to 1 if the system has the type `ulong'. */
#define HAVE_ULONG 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the `unsetenv' function. */
#define HAVE_UNSETENV 1

/* Defined if time_t is an unsigned type */
/* #undef HAVE_UNSIGNED_TIME_T */

/* Define to 1 if the system has the type `ushort'. */
#define HAVE_USHORT 1

/* Define to 1 if you have the `vfork' function. */
#define HAVE_VFORK 1

/* Define to 1 if you have the <vfork.h> header file. */
/* #undef HAVE_VFORK_H */

/* Define to 1 if you have the `vprintf' function. */
#define HAVE_VPRINTF 1

/* Defined if we run on WindowsCE */
/* #undef HAVE_W32CE_SYSTEM */

/* Defined if we run on a W32 API based system */
/* #undef HAVE_W32_SYSTEM */

/* Define to 1 if you have the `wait4' function. */
#define HAVE_WAIT4 1

/* Define to 1 if you have the `waitpid' function. */
#define HAVE_WAITPID 1

/* Define to 1 if you have the <winsock2.h> header file. */
/* #undef HAVE_WINSOCK2_H */

/* Define to 1 if `fork' works. */
#define HAVE_WORKING_FORK 1

/* Define to 1 if `vfork' works. */
#define HAVE_WORKING_VFORK 1

/* Define to 1 if you have the <ws2tcpip.h> header file. */
/* #undef HAVE_WS2TCPIP_H */

/* Defined if ZIP and ZLIB are supported */
#define HAVE_ZIP 1

/* Enable GNUTLS support in http.c */
#define HTTP_USE_GNUTLS 1

/* Enable NTBTLS support in http.c */
/* #undef HTTP_USE_NTBTLS */

/* Define as const if the declaration of iconv() needs const. */
#define ICONV_CONST 

/* Defined if this is not a regular release */
/* #undef IS_DEVELOPMENT_VERSION */

/* Requested API version for libassuan */
#define LIBASSUAN_API_REQUESTED $req_libassuan_api

/* Defined if the host has little endian byte ordering */
#define LITTLE_ENDIAN_HOST 1

/* Defined if this build is in maintainer mode */
/* #undef MAINTAINER_MODE */

/* Tool with sendmail -t interface */
#define NAME_OF_SENDMAIL ""

/* Required version of Libksba */
#define NEED_KSBA_VERSION "1.4.0"

/* Define if the LDAP library requires including lber.h before ldap.h */
/* #undef NEED_LBER_H */

/* Required version of Libgcrypt */
#define NEED_LIBGCRYPT_VERSION "1.8.0"

/* Required version of NTBTLS */
#define NEED_NTBTLS_VERSION "0.2.0"

/* Define to disable all external program execution */
/* #undef NO_EXEC */

/* Define to include only trust-model always */
/* #undef NO_TRUST_MODELS */

/* Build with debug version of nPth */
/* #undef NPTH_ENABLE_DEBUG */

/* Name of this package */
#define PACKAGE "gnupg"

/* Bug report address */
#define PACKAGE_BUGREPORT "https://bugs.gnupg.org"

/* Name of this package for gettext */
#define PACKAGE_GT "gnupg2"

/* Define to the full name of this package. */
#define PACKAGE_NAME "gnupg"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "gnupg 2.2.43"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "gnupg"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "2.2.43"

/* Size of the key and UID caches */
#define PK_UID_CACHE_SIZE 4096

/* A human readable text with the name of the OS */
#define PRINTABLE_OS_NAME "GNU/Linux"

/* Defined if "make check" shall run all tests */
/* #undef RUN_ALL_TESTS */

/* The displayed name of scdaemon */
#define SCDAEMON_DISP_NAME "SCDaemon"

/* The name of the scdaemon */
#define SCDAEMON_NAME "scdaemon"

/* The name of the SCdaemon socket */
#define SCDAEMON_SOCK_NAME "S.scdaemon"

/* Size of secure memory buffer */
#define SECMEM_BUFFER_SIZE 32768

/* defines the filename of the shred program */
#define SHRED "/usr/bin/shred"

/* The size of `time_t', as computed by sizeof. */
#define SIZEOF_TIME_T 8

/* The size of `unsigned int', as computed by sizeof. */
#define SIZEOF_UNSIGNED_INT 4

/* The size of `unsigned long', as computed by sizeof. */
#define SIZEOF_UNSIGNED_LONG 8

/* The size of `unsigned long long', as computed by sizeof. */
#define SIZEOF_UNSIGNED_LONG_LONG 8

/* The size of `unsigned short', as computed by sizeof. */
#define SIZEOF_UNSIGNED_SHORT 2

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define to enable auto starting of the dirmngr */
#define USE_DIRMNGR_AUTO_START 1

/* Define to install gpg as gpg2 */
/* #undef USE_GPG2_HACK */

/* Defined if LDAP is support */
/* #undef USE_LDAP */

/* Build with integrated libdns support */
#define USE_LIBDNS 1

/* Defined if support for nPth is requested and nPth is available */
#define USE_NPTH 1

/* Set this to limit filenames to the 8.3 format */
/* #undef USE_ONLY_8DOT3 */

/* If defined try /run/gnupg/user before /run/user */
/* #undef USE_RUN_GNUPG_USER_SOCKET */

/* Because the Unix gettext has too much overhead on MingW32 systems and these
   systems lack Posix functions, we use a simplified version of gettext */
/* #undef USE_SIMPLE_GETTEXT */

/* Enable extensions on AIX 3, Interix.  */
#ifndef _ALL_SOURCE
# define _ALL_SOURCE 1
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# define _GNU_SOURCE 1
#endif
/* Enable threading extensions on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
# define _POSIX_PTHREAD_SEMANTICS 1
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# define _TANDEM_SOURCE 1
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
# define __EXTENSIONS__ 1
#endif


/* Enable to build the TOFU code */
/* #undef USE_TOFU */

/* Version of this package */
#define VERSION "2.2.43"

/* Expose all libc features (__DARWIN_C_FULL). */
/* #undef _DARWIN_C_SOURCE */

/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Define to 1 to make fseeko visible on some hosts (e.g. glibc 2.2). */
/* #undef _LARGEFILE_SOURCE */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* Define to 1 if on MINIX. */
/* #undef _MINIX */

/* Define to 2 if the system does not provide POSIX.1 features except with
   this defined. */
/* #undef _POSIX_1_SOURCE */

/* Define to 1 if you need to in order for `stat' and other things to work. */
/* #undef _POSIX_SOURCE */

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif

/* Define to `int' if <sys/types.h> does not define. */
/* #undef mode_t */

/* Define to `int' if <sys/types.h> does not define. */
/* #undef pid_t */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */

/* type to use in place of socklen_t if not defined */
/* #undef socklen_t */

/* Define as `fork' if `vfork' does not work. */
/* #undef vfork */

/* Define to empty if the keyword `volatile' does not work. Warning: valid
   code using `volatile' can become incorrect without. Disable with care. */
/* #undef volatile */


/* This is the major version number of GnuPG so that
   source included files can test for this.  Note, that
   we use 2 here even for GnuPG 1.9.x. */
#define GNUPG_MAJOR_VERSION 2

/* Now to separate file name parts.
   Please note that the string version must not contain more
   than one character because the code assumes strlen()==1 */
#ifdef HAVE_DOSISH_SYSTEM
#define DIRSEP_C '\\'
#define DIRSEP_S "\\"
#define EXTSEP_C '.'
#define EXTSEP_S "."
#define PATHSEP_C ';'
#define PATHSEP_S ";"
#define EXEEXT_S ".exe"
#else
#define DIRSEP_C '/'
#define DIRSEP_S "/"
#define EXTSEP_C '.'
#define EXTSEP_S "."
#define PATHSEP_C ':'
#define PATHSEP_S ":"
#define EXEEXT_S ""
#endif

/* This is the same as VERSION, but should be overridden if the
   platform cannot handle things like dots '.' in filenames. Set
   SAFE_VERSION_DOT and SAFE_VERSION_DASH to whatever SAFE_VERSION
   uses for dots and dashes. */
#define SAFE_VERSION VERSION
#define SAFE_VERSION_DOT  '.'
#define SAFE_VERSION_DASH '-'

/* Some global constants.
 * Note that the homedir must not end in a slash.  */
#ifdef HAVE_DOSISH_SYSTEM
# ifdef HAVE_DRIVE_LETTERS
#  define GNUPG_DEFAULT_HOMEDIR "c:/gnupg"
# else
#  define GNUPG_DEFAULT_HOMEDIR "/gnupg"
# endif
#elif defined(__VMS)
#define GNUPG_DEFAULT_HOMEDIR "/SYS$LOGIN/gnupg"
#else
#define GNUPG_DEFAULT_HOMEDIR "~/.gnupg"
#endif
#define GNUPG_PRIVATE_KEYS_DIR  "private-keys-v1.d"
#define GNUPG_OPENPGP_REVOC_DIR "openpgp-revocs.d"

#define GNUPG_DEF_COPYRIGHT_LINE "Copyright (C) 2023 g10 Code GmbH"


/* For some systems (DOS currently), we hardcode the path here.  For
   POSIX systems the values are constructed by the Makefiles, so that
   the values may be overridden by the make invocations; this is to
   comply with the GNU coding standards.  Note that these values are
   only defaults.  */
#ifdef HAVE_DOSISH_SYSTEM
# ifdef HAVE_DRIVE_LETTERS
#  define GNUPG_BINDIR      "c:\\gnupg"
#  define GNUPG_LIBEXECDIR  "c:\\gnupg"
#  define GNUPG_LIBDIR      "c:\\gnupg"
#  define GNUPG_DATADIR     "c:\\gnupg"
#  define GNUPG_SYSCONFDIR  "c:\\gnupg"
# else
#  define GNUPG_BINDIR      "\\gnupg"
#  define GNUPG_LIBEXECDIR  "\\gnupg"
#  define GNUPG_LIBDIR      "\\gnupg"
#  define GNUPG_DATADIR     "\\gnupg"
#  define GNUPG_SYSCONFDIR  "\\gnupg"
# endif
#endif

/* Derive some other constants. */
#if !(defined(HAVE_FORK) && defined(HAVE_PIPE) && defined(HAVE_WAITPID))
#define EXEC_TEMPFILE_ONLY
#endif


/* We didn't define endianness above, so get it from OS macros.  This
   is intended for making fat binary builds on OS X. */
#if !defined(BIG_ENDIAN_HOST) && !defined(LITTLE_ENDIAN_HOST)
#if defined(__BIG_ENDIAN__)
#define BIG_ENDIAN_HOST 1
#elif defined(__LITTLE_ENDIAN__)
#define LITTLE_ENDIAN_HOST 1
#else
#error "No endianness found"
#endif
#endif


/* Hack used for W32: ldap.m4 also tests for the ASCII version of
   ldap_start_tls_s because that is the actual symbol used in the
   library.  winldap.h redefines it to our commonly used value,
   thus we define our usual macro here.  */
#ifdef HAVE_LDAP_START_TLS_SA
# ifndef HAVE_LDAP_START_TLS_S
#  define HAVE_LDAP_START_TLS_S 1
# endif
#endif

/* Provide the es_ macro for estream.  */
#define GPGRT_ENABLE_ES_MACROS 1

/* We want the argparse macros from gpgrt.  */
#define GPGRT_ENABLE_ARGPARSE_MACROS 1

/* Tell libgcrypt not to use its own libgpg-error implementation. */
#define USE_LIBGPG_ERROR 1

/* Tell Libgcrypt not to include deprecated definitions.  */
#define GCRYPT_NO_DEPRECATED 1

/* Our HTTP code is used in estream mode.  */
#define HTTP_USE_ESTREAM 1

/* Under W32 we do an explicit socket initialization, thus we need to
   avoid the on-demand initialization which would also install an atexit
   handler.  */
#define HTTP_NO_WSASTARTUP

/* Under Windows we use the gettext code from libgpg-error.  */
#define GPG_ERR_ENABLE_GETTEXT_MACROS

/* Under WindowsCE we use the strerror replacement from libgpg-error.  */
#define GPG_ERR_ENABLE_ERRNO_MACROS

#endif /*GNUPG_CONFIG_H_INCLUDED*/

