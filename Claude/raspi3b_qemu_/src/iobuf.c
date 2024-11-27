/* Simplified iobuf.c for bare metal systems 
 * Based on GPG's iobuf.c but heavily modified for minimal dependencies
 */

#include <stdint.h>
#include <stddef.h>
#include "memory.h"

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

struct iobuf_struct {
    int use;               /* Type of buffer */
    struct {
        byte *buf;         /* Data buffer */
        size_t start;      /* Start offset */
        size_t len;        /* Length of data */ 
        size_t size;       /* Total size of buffer */
    } d;
    
    int filter_eof;        /* EOF flag */
    int error;            /* Last error code */
    unsigned long nlimit;  /* Read limit */
    unsigned long nbytes;  /* Bytes processed */
    unsigned long ntotal;  /* Total bytes processed */
    int nofast;           /* Flag for slow path */
    
    /* Filter info */
    int (*filter)(void *opaque, int control,
                  iobuf_t chain, byte *buffer, size_t *len);
    void *filter_ov;      /* Filter private data */
    int filter_ov_owner;  /* True if we own filter data */
    
    iobuf_t chain;        /* Next filter in chain */
    
    int no;               /* Debug number */
    int subno;           /* Sub-number */
};

static void *xmalloc(size_t n) {
    /* Add your memory allocator here */
    return NULL; 
}

static void *xcalloc(size_t n, size_t m) {
    /* Add your calloc implementation */
    return NULL;
}

static void xfree(void *p) {
    /* Add your free implementation */
}

static void *xrealloc(void *p, size_t n) { 
    /* Add your realloc implementation */
    return NULL;
}

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
    return a;
}

/* Free IOBUF chain */
int iobuf_close(iobuf_t a) {
    iobuf_t a_chain;
    size_t dummy_len = 0;
    int rc = 0;
    
    for (; a; a = a_chain) {
        a_chain = a->chain;
        
        if (a->filter) {
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
    if (a->use != IOBUF_OUTPUT && a->use != IOBUF_OUTPUT_TEMP)
        return -1;
        
    if (a->d.len == a->d.size) {
        size_t len = a->d.len;
        int rc = a->filter(a->filter_ov, IOBUFCTRL_FLUSH,
                          a->chain, a->d.buf, &len);
        if (rc)
            return rc;
        a->d.len = 0;
    }
    
    a->d.buf[a->d.len++] = c;
    return 0;
}

/* Write data to IOBUF */
int iobuf_write(iobuf_t a, const void *buffer, unsigned int buflen) {
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

/* Push a filter onto IOBUF */
int iobuf_push_filter(iobuf_t a,
                     int (*f)(void *opaque, int control,
                             iobuf_t chain, byte *buf, size_t *len),
                     void *ov) {
                         
    iobuf_t b;
    size_t dummy_len = 0;
    int rc = 0;
    
    if (a->subno >= MAX_NESTING_FILTER)
        return GPG_ERR_BAD_DATA;
        
    /* Create new filter and copy state */
    b = xmalloc(sizeof *b);
    *b = *a;
    
    /* Setup filter chain */
    a->filter = f;
    a->filter_ov = ov;
    a->filter_eof = 0;
    a->chain = b;
    a->d.buf = xmalloc(a->d.size);
    a->d.len = 0;
    a->d.start = 0;
    a->subno++;
    
    /* Initialize filter */
    if (f && (rc = f(ov, IOBUFCTRL_INIT, b, NULL, &dummy_len)))
        return rc;
        
    return 0;
}

/* Remove filter from IOBUF */
int iobuf_pop_filter(iobuf_t a, 
                    int (*f)(void *opaque, int control,
                            iobuf_t chain, byte *buf, size_t *len),
                    void *ov) {
                        
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

/* Block filter implementation */
static int block_filter(void *opaque, int control,
                       iobuf_t chain, byte *buffer, size_t *ret_len) {
                           
    block_filter_ctx_t *a = opaque;
    size_t size = *ret_len;
    char *buf = (char*)buffer;
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
                
                *buf++ = c;
                size--;
                a->size--;
                n++;
            }
        }
        
        *ret_len = n;
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

/* Wipe memory contents */
static void wipememory(void *ptr, size_t len) {
    volatile char *p = (volatile char *)ptr;
    while (len--)
        *p++ = 0;
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
    // else if (a->use != IOBUF_OUTPUT)
    //     printf("flush on non-output iobuf\n");  // log_bug
    // else if (!a->filter)
    //     printf("filter_flush: no filter\n");    // log_bug

    len = a->d.len;
    rc = a->filter(a->filter_ov, IOBUFCTRL_FLUSH, a->chain, a->d.buf, &len);
    if (!rc && len != a->d.len) {
        // printf("filter_flush did not write all!\n");
        rc = -1;  // GPG_ERR_INTERNAL
    }
    else if (rc)
        a->error = rc;

    a->d.len = 0;
    return rc;
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