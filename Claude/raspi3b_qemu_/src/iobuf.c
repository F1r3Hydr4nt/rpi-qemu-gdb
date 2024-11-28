/* Simplified iobuf.c for bare metal systems 
 * Based on GPG's iobuf.c but heavily modified for minimal dependencies
 */

#include <stdint.h>
#include <stddef.h>
#include "memory.h"
#include "printf.h"

#include "filter.h"
#include "packet.h"
/* Configuration */
#define IOBUF_BUFFER_SIZE   8192
#define MAX_NESTING_FILTER  64 

/* Buffer types */
#define IOBUF_INPUT    1
#define IOBUF_OUTPUT   2
#define IOBUF_INPUT_TEMP  3 
#define IOBUF_OUTPUT_TEMP 4

/* Control commands */
#define IOBUFCTRL_INIT      1
#define IOBUFCTRL_FREE      2
#define IOBUFCTRL_UNDERFLOW 3
#define IOBUFCTRL_FLUSH     4
#define IOBUFCTRL_DESC      5
#define IOBUFCTRL_CANCEL    6

/* Error codes */
#define GPG_ERR_BAD_DATA   (-1) 

/* Basic types */
typedef uint8_t byte;
typedef struct iobuf_struct *iobuf_t;

/* Debug logging macros */
#ifdef DEBUG_IOBUF
#define DBG_IOBUF 1 
#else
#define DBG_IOBUF 0
#endif

// static void *xmalloc(size_t n) {
//     /* Add your memory allocator here */
//     return NULL; 
// }

// static void *xcalloc(size_t n, size_t m) {
//     /* Add your calloc implementation */
//     return NULL;
// }

// static void xfree(void *p) {
//     /* Add your free implementation */
// }

// static void *xrealloc(void *p, size_t n) { 
//     /* Add your realloc implementation */
//     return NULL;
// }

/* Block filter context for length processing */
typedef struct {
    int use;           /* Type of use */
    size_t size;      /* Block size */
    size_t count;     /* Current count */
    int partial;      /* Partial data flag */ 
    char *buffer;     /* Temp buffer */
    size_t buflen;    /* Buffer length */
    int first_c;      /* First character */  
    int eof;          /* EOF flag */
} block_filter_ctx_t;

/* Create new IOBUF */
iobuf_t iobuf_alloc(int use, size_t bufsize) {
    static int number = 0;
    iobuf_t a;
    
    if (bufsize == 0)
        bufsize = IOBUF_BUFFER_SIZE;
        
    a = xcalloc(1, sizeof *a);
    a->use = use;
    a->d.buf = xmalloc(bufsize); 
    a->d.size = bufsize;
    a->no = ++number;
    printf("iobuf_alloc %d\n",a->use);
    return a;
}

/* Free IOBUF chain */
int iobuf_close(iobuf_t a) {
    log_hexdump(a->d.buf, a->d.len);
    printf("iobuf_close\n");
   // print_iobuf_info2(a);
    // printf("iobuf_close %d\n",a->no);
    iobuf_t a_chain;
    size_t dummy_len = 0;
    int rc = 0;
    
    for (; a; a = a_chain) {
        a_chain = a->chain;
        
        if (a->filter) {
            printf("a->filter\n");
            rc = a->filter(a->filter_ov, IOBUFCTRL_FREE, 
                          a->chain, NULL, &dummy_len);
        }
        
        if (a->filter_ov && a->filter_ov_owner)
            xfree(a->filter_ov);
            
        if (a->d.buf)
            xfree(a->d.buf);
            
        xfree(a);
    }    

    return rc;
}

/* Read byte from IOBUF */
int iobuf_readbyte(iobuf_t a) {
    if (a->use != IOBUF_INPUT && a->use != IOBUF_INPUT_TEMP)
        return -1;
        
    if (a->nlimit && a->nbytes >= a->nlimit)
        return -1;  /* EOF */
        
    if (a->d.start < a->d.len) {
        int c = a->d.buf[a->d.start++];
        a->nbytes++;
        return c;
    }
    
    /* Need to read more data via filter */
    if (a->filter && !a->filter_eof) {
        size_t len = a->d.size;
        int rc = a->filter(a->filter_ov, IOBUFCTRL_UNDERFLOW,
                          a->chain, a->d.buf, &len);
                          
        if (rc == -1 || len == 0) {
            a->filter_eof = 1;
            return -1;
        }
        
        a->d.len = len;
        a->d.start = 1;
        a->nbytes++;
        return a->d.buf[0];
    }
    
    return -1;  /* EOF */
}

/* Write byte to IOBUF */ 
int iobuf_writebyte(iobuf_t a, unsigned int c) {
    printf("iobuf_writebyte %02X a->use %d\n", c, a->use);
    if (a->use != IOBUF_OUTPUT && a->use != IOBUF_OUTPUT_TEMP){
        printf("BIG ERROR\n");
        return -1;
    }
        
    if (a->d.len == a->d.size) {
        size_t len = a->d.len;
        int rc = a->filter(a->filter_ov, IOBUFCTRL_FLUSH,
                          a->chain, a->d.buf, &len);
                                  //printf("Adn here %d\n", rc);

        if (rc)
            return rc;
        a->d.len = 0;
    }
    
    a->d.buf[a->d.len++] = c;
    return 0;
}

/* Write data to IOBUF */
int iobuf_write(iobuf_t a, const void *buffer, unsigned int buflen) {
      printf("iobuf_write %d\n",buflen);

    const byte *buf = buffer;
    int rc;
    
    if (a->use != IOBUF_OUTPUT && a->use != IOBUF_OUTPUT_TEMP)
        return -1;
        
    while (buflen > 0) {
        if (a->d.len < a->d.size) {
            size_t space = a->d.size - a->d.len;
            size_t count = space < buflen ? space : buflen;
            
            for (size_t i = 0; i < count; i++)
                a->d.buf[a->d.len++] = buf[i];
                
            buf += count;
            buflen -= count;
        }
        
        if (buflen > 0) {
            size_t len = a->d.len;
            rc = a->filter(a->filter_ov, IOBUFCTRL_FLUSH,
                          a->chain, a->d.buf, &len);
            if (rc)
                return rc;
            a->d.len = 0;
        }
    }
    
    return 0;
}

/****************
 * Register an i/o filter.
 */
int
iobuf_push_filter (iobuf_t a,
		   int (*f) (void *opaque, int control,
			     iobuf_t chain, byte * buf, size_t * len),
                   void *ov)
{
//cipher_filter_cfb (void *opaque, int control,
                   // iobuf_t chain, byte *buf, size_t *len)

   printf("iobuf_push_filter %d\n",a->use);
  return iobuf_push_filter2 (a, f, ov, 0);
}

int
iobuf_push_filter2 (iobuf_t a,
		    int (*f) (void *opaque, int control,
			      iobuf_t chain, byte * buf, size_t * len),
		    void *ov, int rel_ov)
{
  //printf("iobuf_push_filter2 %d\n",a->use);
  iobuf_t b;
  size_t dummy_len = 0;
  int rc = 0;
    // printf("filter_flush failed %d\n",a->filter);

  if (a->use == IOBUF_OUTPUT && (rc = filter_flush (a))){
    printf("filter_flush failed\n");
    return rc;
  }
  if (a->subno >= MAX_NESTING_FILTER)
    {
      printf ("i/o filter too deeply nested - corrupted data?\n");
      return -1;//GPG_ERR_BAD_DATA;
    }

  /* We want to create a new filter and put it in front of A.  A
     simple implementation would do:

       b = iobuf_alloc (...);
       b->chain = a;
       return a;

     This is a bit problematic: A is the head of the pipeline and
     there are potentially many pointers to it.  Requiring the caller
     to update all of these pointers is a burden.

     An alternative implementation would add a level of indirection.
     For instance, we could use a pipeline object, which contains a
     pointer to the first filter in the pipeline.  This is not what we
     do either.

     Instead, we allocate a new buffer (B) and copy the first filter's
     state into that and use the initial buffer (A) for the new
     filter.  One limitation of this approach is that it is not
     practical to maintain a pointer to a specific filter's state.

     Before:

           A
           |
           v 0x100               0x200
           +----------+          +----------+
           | filter x |--------->| filter y |---->....
           +----------+          +----------+

     After:           B
                      |
                      v 0x300
                      +----------+
           A          | filter x |
           |          +----------+
           v 0x100    ^          v 0x200
           +----------+          +----------+
           | filter w |          | filter y |---->....
           +----------+          +----------+

     Note: filter x's address changed from 0x100 to 0x300, but A still
     points to the head of the pipeline.
  */

  b = xmalloc (sizeof *b);
  memcpy (b, a, sizeof *b);
  /* fixme: it is stupid to keep a copy of the name at every level
   * but we need the name somewhere because the name known by file_filter
   * may have been released when we need the name of the file */
  //b->real_fname = a->real_fname ? xstrdup (a->real_fname) : NULL;
  /* remove the filter stuff from the new stream */
  a->filter = NULL;
  a->filter_ov = NULL;
  a->filter_ov_owner = 0;
  a->filter_eof = 0;
  if (a->use == IOBUF_OUTPUT_TEMP)
    /* A TEMP filter buffers any data sent to it; it does not forward
       any data down the pipeline.  If we add a new filter to the
       pipeline, it shouldn't also buffer data.  It should send it
       downstream to be buffered.  Thus, the correct type for a filter
       added in front of an IOBUF_OUTPUT_TEMP filter is IOBUF_OUPUT, not
       IOBUF_OUTPUT_TEMP.  */
    {
      a->use = IOBUF_OUTPUT;

      /* When pipeline is written to, the temp buffer's size is
	 increased accordingly.  We don't need to allocate a 10 MB
	 buffer for a non-terminal filter.  Just use the default
	 size.  */
      a->d.size = IOBUF_BUFFER_SIZE;
    }
  else if (a->use == IOBUF_INPUT_TEMP)
    /* Same idea as above.  */
    {
      a->use = IOBUF_INPUT;
      a->d.size = IOBUF_BUFFER_SIZE;
    }

  /* The new filter (A) gets a new buffer.

     If the pipeline is an output or temp pipeline, then giving the
     buffer to the new filter means that data that was written before
     the filter was pushed gets sent to the filter.  That's clearly
     wrong.

     If the pipeline is an input pipeline, then giving the buffer to
     the new filter (A) means that data that has read from (B), but
     not yet read from the pipeline won't be processed by the new
     filter (A)!  That's certainly not what we want.  */
  a->d.buf = xmalloc (a->d.size);
  a->d.len = 0;
  a->d.start = 0;

  /* disable nlimit for the new stream */
  a->ntotal = b->ntotal + b->nbytes;
  a->nlimit = a->nbytes = 0;
  a->nofast = 0;
  /* make a link from the new stream to the original stream */
  a->chain = b;

  /* setup the function on the new stream */
  a->filter = f;
  a->filter_ov = ov;
  a->filter_ov_owner = rel_ov;

  a->subno = b->subno + 1;

//   if (DBG_IOBUF)
//     {
//       byte desc[MAX_IOBUF_DESC];
//       log_debug ("iobuf-%d.%d: push '%s'\n",
// 		 a->no, a->subno, iobuf_desc (a, desc));
//       print_chain (a);
//     }

  /* now we can initialize the new function if we have one */
  if (a->filter && (rc = a->filter (a->filter_ov, IOBUFCTRL_INIT, a->chain,
				    NULL, &dummy_len)))
    printf ("IOBUFCTRL_INIT failed: %d\n", rc);//, gpg_strerror (rc));
  return rc;
}

/* Remove filter from IOBUF */
int iobuf_pop_filter(iobuf_t a, 
                    int (*f)(void *opaque, int control,
                            iobuf_t chain, byte *buf, size_t *len),
                    void *ov) {
       printf("iobuf_pop_filter\n");                 
    iobuf_t b;
    size_t dummy_len = 0;
    int rc = 0;
    
    if (!a->filter)
        return 0;
        
    /* Find matching filter */
    for (b = a; b; b = b->chain)
        if (b->filter == f && (!ov || b->filter_ov == ov))
            break;
            
    if (!b)
        return 0;
        
    /* Free filter */
    if (b->filter)
        rc = b->filter(b->filter_ov, IOBUFCTRL_FREE,
                      b->chain, NULL, &dummy_len);
                      
    if (b->filter_ov && b->filter_ov_owner)
        xfree(b->filter_ov);
        
    /* Remove from chain */
    if (a == b) {
        b = a->chain;
        xfree(a->d.buf);
        *a = *b;
        xfree(b);
    }
    
    return rc;
}


#define MAX_IOBUF_DESC 32

static iobuf_t
do_open (const char *fname, int special_filenames,
	 int use, const char *opentype, int mode700)
{
  iobuf_t a;
  // gnupg_fd_t fp;
  // file_filter_ctx_t *fcx;
  size_t len = 0;
  int print_only = 0;
  int fd;
  byte desc[MAX_IOBUF_DESC];

  // log_assert (use == IOBUF_INPUT || use == IOBUF_OUTPUT);

//   if (special_filenames
//       /* NULL or '-'.  */
//       && (!fname || (*fname == '-' && !fname[1])))
//     {
//       if (use == IOBUF_INPUT)
// 	{
// 	  // fp = FD_FOR_STDIN;
// 	  fname = "[stdin]";
// 	}
//       else
// 	{
// 	  // fp = FD_FOR_STDOUT;
// 	  fname = "[stdout]";
// 	}
//       print_only = 1;
//     }
//   else if (!fname)
//     return NULL;
//   else if (special_filenames
//            && (fd = check_special_filename (fname, 0, 1)) != -1)
//     return iobuf_fdopen (translate_file_handle (fd, use == IOBUF_INPUT ? 0 : 1),
// 			 opentype);
  // else
    // {
    //   if (use == IOBUF_INPUT)
	// fp = fd_cache_open (fname, opentype);
    //   else
	// fp = direct_open (fname, opentype, mode700);
    // //   if (fp == GNUPG_INVALID_FD)
	// // return NULL;
    // }

  a = iobuf_alloc (use, IOBUF_BUFFER_SIZE);
  // fcx = xmalloc (sizeof *fcx + strlen (fname));
  // fcx->fp = fp;
  // fcx->print_only_name = print_only;
  // strcpy (fcx->fname, fname);
//   if (!print_only)
//     a->real_fname = xstrdup (fname);
  a->filter = text_filter;
  // a->filter_ov = fcx;
  // file_filter (fcx, IOBUFCTRL_INIT, NULL, NULL, &len);
//   if (DBG_IOBUF)
//     log_debug ("iobuf-%d.%d: open '%s' desc=%s fd=%d\n",
// 	       a->no, a->subno, fname, iobuf_desc (a, desc), FD2INT (fcx->fp));

  return a;
}

iobuf_t
iobuf_create (const char *fname, int mode700)
{
  return do_open (fname, 0, IOBUF_OUTPUT, "wb", mode700);
}

const char* control_mode_str[] = {
    "UNKNOWN",
    "IOBUFCTRL_INIT",
    "IOBUFCTRL_FREE",
    "IOBUFCTRL_UNDERFLOW",
    "IOBUFCTRL_FLUSH",
    "IOBUFCTRL_DESC",
    "IOBUFCTRL_CANCEL",
    "IOBUFCTRL_PEEK",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "UNKNOWN",
    "IOBUFCTRL_USER"
};
/* Block filter implementation */
int block_filter(void *opaque, int control,
                       iobuf_t chain, byte *buf, size_t *len) {
                
printf("block_filter %s\n", control_mode_str[control]);
           
    block_filter_ctx_t *a = opaque;
    size_t size = *len;
    char *buffer = (char*)buf;
    int rc = 0;
    
    if (control == IOBUFCTRL_UNDERFLOW) {
        size_t n = 0;
        
        if (a->eof)
            rc = -1;
            
        while (!rc && size > 0) {
            if (!a->size) {
                if (a->partial == 2) {
                    a->eof = 1;
                    if (!n)
                        rc = -1;
                    break;
                }
                
                /* Get new partial length */
                if (a->partial) {
                    int c;
                    
                    if (a->first_c) {
                        c = a->first_c;
                        a->first_c = 0;
                    }
                    else {
                        c = iobuf_readbyte(chain);
                        if (c == -1) {
                            rc = GPG_ERR_BAD_DATA;
                            break;
                        }
                    }
                    
                    /* Parse length encoding */
                    if (c < 192)
                        a->size = c;
                    else if (c < 224) {
                        a->size = (c - 192) * 256;
                        c = iobuf_readbyte(chain);
                        if (c == -1) {
                            rc = GPG_ERR_BAD_DATA;
                            break;
                        }
                        a->size += c + 192;
                    }
                    else if (c == 255) {
                        uint32_t len = 0;
                        for (int i = 0; i < 4; i++) {
                            c = iobuf_readbyte(chain);
                            if (c == -1) {
                                rc = GPG_ERR_BAD_DATA;
                                break;
                            }
                            len = (len << 8) | c;
                        }
                        a->size = len;
                    }
                    else {
                        a->size = 1 << (c & 0x1f);
                    }
                    
                    a->partial = a->size ? 2 : 1;
                }
            }
            
            /* Copy data */
            while (!rc && size > 0 && a->size > 0) {
                int c = iobuf_readbyte(chain);
                if (c == -1) {
                    rc = GPG_ERR_BAD_DATA;
                    break;
                }
                
                *buffer++ = c;
                size--;
                a->size--;
                n++;
            }
        }
        
        *len = n;
    }
    else if (control == IOBUFCTRL_FLUSH) {
        if (a->partial) {
            /* Write partial length header */
            if (size < 192) {
                if (iobuf_writebyte(chain, size))
                    return GPG_ERR_BAD_DATA;
            }
            else if (size < 8384) {
                if (iobuf_writebyte(chain, ((size-192)/256) + 192)
                    || iobuf_writebyte(chain, (size-192)%256))
                    return GPG_ERR_BAD_DATA;
            }
            else {
                if (iobuf_writebyte(chain, 0xff)
                    || iobuf_writebyte(chain, (size >> 24) & 0xff)
                    || iobuf_writebyte(chain, (size >> 16) & 0xff)
                    || iobuf_writebyte(chain, (size >> 8) & 0xff)
                    || iobuf_writebyte(chain, size & 0xff))
                    return GPG_ERR_BAD_DATA;
            }
            
            /* Write data */
            if (size && iobuf_write(chain, buffer, size))
                return GPG_ERR_BAD_DATA;
        }
    }
    else if (control == IOBUFCTRL_INIT) {
        a->size = 0;
        a->eof = 0;
        a->buffer = NULL;
        a->buflen = 0;
    }
    else if (control == IOBUFCTRL_FREE) {
        xfree(a->buffer);
    }
    
    return rc;
}

/****************
 * Enable or disable partial body length mode (RFC 4880 4.2.2.4).
 *
 * If LEN is 0, this disables partial block mode by popping the
 * partial body length filter, which must be the most recently
 * added filter.
 *
 * If LEN is non-zero, it pushes a partial body length filter.  If
 * this is a read filter, LEN must be the length byte from the first
 * chunk and A should be position just after this first partial body
 * length header.
 */
void
iobuf_set_partial_body_length_mode (iobuf_t a, size_t len)
{
  printf ("iobuf_set_partial_body_length_mode %d\n", len);
  if (!len)
    /* Disable partial body length mode.  */
    {
      if (a->use == IOBUF_INPUT)
	printf ("iobuf_pop_filter called in set_partial_block_mode"
		   " - please report\n");
      
      printf ("iobuf_pop_filter called in set_partial_block_mode");
      // log_assert (a->filter == block_filter);
      iobuf_pop_filter (a, block_filter, NULL);
    }
  else
    /* Enabled partial body length mode.  */
    {
      block_filter_ctx_t *ctx = xcalloc (1, sizeof *ctx);
      ctx->use = a->use;
      ctx->partial = 1;
      ctx->size = 0;
      ctx->first_c = len;
      
      printf ("pushing partial block filter %d\n", ctx->use);
      iobuf_push_filter (a, block_filter, ctx);
    }
}
/* Enable/disable partial block mode */
void iobuf_set_partial_block_mode(iobuf_t a, size_t len) {
    if (!len) {
        /* Disable partial body length mode */
        if (a->use == IOBUF_INPUT)
            iobuf_pop_filter(a, block_filter, NULL);
    }
    else {
        /* Enable partial body length mode */
        block_filter_ctx_t *ctx = xcalloc(1, sizeof *ctx);
        ctx->use = a->use;
        ctx->partial = 1;
        ctx->size = 0;
        ctx->first_c = len;
        
        iobuf_push_filter(a, block_filter, ctx);
    }
}

/* Read data from IOBUF */
int iobuf_read(iobuf_t a, void *buffer, unsigned int buflen) {
    byte *buf = buffer;
    int c, n = 0;
    
    if (a->use != IOBUF_INPUT && a->use != IOBUF_INPUT_TEMP)
        return -1;
    
    if (a->nlimit) {
        /* Handle read limits */
        while (n < buflen) {
            if ((c = iobuf_readbyte(a)) == -1) {
                if (!n)
                    return -1;
                break;
            }
            if (buf)
                buf[n] = c;
            n++;
        }
        return n;
    }
    
    /* Regular read */
    while (n < buflen) {
        if (a->d.start < a->d.len) {
            unsigned size = a->d.len - a->d.start;
            if (size > buflen - n)
                size = buflen - n;
            if (buf)
                for (unsigned i = 0; i < size; i++)
                    buf[n+i] = a->d.buf[a->d.start+i];
            n += size;
            a->d.start += size;
        }
        else {
            if ((c = iobuf_readbyte(a)) == -1)
                return n ? n : -1;
            if (buf)
                buf[n] = c;
            n++;
        }
    }
    
    a->nbytes += n;
    return n;
}

/* Set read limit */
void iobuf_set_limit(iobuf_t a, unsigned long nlimit) {
    a->nlimit = nlimit;
    a->ntotal += a->nbytes;
    a->nbytes = 0;
}

/* Get current position */
unsigned long iobuf_tell(iobuf_t a) {
    return a->ntotal + a->nbytes;
}

/* Create temp buffer */
iobuf_t iobuf_temp(void) {
    return iobuf_alloc(IOBUF_OUTPUT_TEMP, IOBUF_BUFFER_SIZE);
}

/* Create temp buffer with content */
iobuf_t iobuf_temp_with_content(const char *buffer, size_t length) {
    iobuf_t a;
    
    a = iobuf_alloc(IOBUF_INPUT_TEMP, length);
    if (a && a->d.buf) {
        for (size_t i = 0; i < length; i++)
            a->d.buf[i] = buffer[i];
        a->d.len = length;
    }
    
    return a;
}

/* Write temp buffer to output */
int iobuf_write_temp(iobuf_t dest, iobuf_t source) {
    if (!dest || !source)
        return -1;
    
    if (source->d.len)
        return iobuf_write(dest, source->d.buf, source->d.len);
    
    return 0;
}

size_t iobuf_copy(iobuf_t dest, iobuf_t source) {
    char *temp;
    const size_t temp_size = 32 * 1024;  // Use 32 KB buffer like original
    size_t nread;
    size_t nwrote = 0;
    size_t max_read = 0;
    int err;

    // Validate buffer types
    if (!(source->use == IOBUF_INPUT || source->use == IOBUF_INPUT_TEMP))
        return (size_t)(-1);
    if (!(dest->use == IOBUF_OUTPUT || dest->use == IOBUF_OUTPUT_TEMP))
        return (size_t)(-1);

    // Check for errors
    if (dest->error)
        return (size_t)(-1);

    // Allocate temp buffer
    temp = xmalloc(temp_size);
    if (!temp)
        return (size_t)(-1);

    // Copy data
    while (1) {
        nread = iobuf_read(source, temp, temp_size);
        if (nread == -1)
            // EOF
            break;

        if (nread > max_read)
            max_read = nread;

        err = iobuf_write(dest, temp, nread);
        if (err)
            break;

        nwrote += nread;
    }

    // Security: wipe buffer before freeing
    if (max_read)
        wipememory(temp, max_read);
    xfree(temp);

    return nwrote;
}

static int filter_flush(iobuf_t a) {
    size_t len;
    int rc;

    if (a->use == IOBUF_OUTPUT_TEMP) { 
        /* increase the temp buffer */
        size_t newsize = a->d.size + IOBUF_BUFFER_SIZE;
        // if (DBG_IOBUF)
        //     printf("increasing temp iobuf from %lu to %lu\n",
        //            (unsigned long)a->d.size, (unsigned long)newsize);

        a->d.buf = xrealloc(a->d.buf, newsize);
        a->d.size = newsize;
        return 0;
    }
    else if (a->use != IOBUF_OUTPUT)
        printf("flush on non-output iobuf\n");  // log_bug
    else if (!a->filter)
        printf("filter_flush: no filter\n");    // log_bug

    len = a->d.len;
    rc = a->filter(a->filter_ov, IOBUFCTRL_FLUSH, a->chain, a->d.buf, &len);
    if (!rc && len != a->d.len) {
        printf("filter_flush did not write all!\n");
        rc = -1;  // GPG_ERR_INTERNAL
    }
    else if (rc)
        a->error = rc;

    a->d.len = 0;
    return rc;
}


int iobuf_flush(iobuf_t a) {
    while (1) {
        int rc = filter_flush(a);
        if (rc) {
            printf("Flushing iobuf failed\n");
            return rc;
        }
        if (!a->chain)
            break;
        a = a->chain;
    }
    return 0;
}


size_t iobuf_temp_to_buffer(iobuf_t a, byte *buffer, size_t buflen) {
    size_t n;

    // Flush each filter in the pipeline
    while (1) {
        int rc = filter_flush(a);
        if (rc) {
            // printf("Flushing iobuf %d.%d failed. Ignoring.\n", 
                   //a->no, a->subno);
        }
        if (!a->chain)
            break;
        a = a->chain;
    }

    // Get final length and copy data
    n = a->d.len;
    if (n > buflen)
        n = buflen;
    memcpy(buffer, a->d.buf, n);
    
    return n;
}