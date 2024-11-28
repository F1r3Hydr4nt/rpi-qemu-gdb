#ifndef IOBUF_H
#define IOBUF_H

#include <stdint.h>
#include <stddef.h>

/* Buffer types */

enum iobuf_use
  {
    /* Pipeline is in input mode.  The data flows from the end to the
       beginning.  That is, when reading from the pipeline, the first
       filter gets its input from the second filter, etc.  */
    IOBUF_INPUT,
    /* Pipeline is in input mode.  The last filter in the pipeline is
       a temporary buffer from which the data is "read".  */
    IOBUF_INPUT_TEMP,
    /* Pipeline is in output mode.  The data flows from the beginning
       to the end.  That is, when writing to the pipeline, the user
       writes to the first filter, which transforms the data and sends
       it to the second filter, etc.  */
    IOBUF_OUTPUT,
    /* Pipeline is in output mode.  The last filter in the pipeline is
       a temporary buffer that grows as necessary.  */
    IOBUF_OUTPUT_TEMP
  };
#define IOBUF_FILELENGTH_LIMIT 0xffffffff

/* Control commands */
enum
  {
    IOBUFCTRL_INIT	= 1,
    IOBUFCTRL_FREE	= 2,
    IOBUFCTRL_UNDERFLOW = 3,
    IOBUFCTRL_FLUSH     = 4,
    IOBUFCTRL_DESC	= 5,
    IOBUFCTRL_CANCEL    = 6,
    IOBUFCTRL_PEEK      = 7,
    IOBUFCTRL_USER	= 16
  };

/* Return any pending error on filter A.  */
#define iobuf_error(a)	      ((a)->error)
#define iobuf_get_temp_length(a) ( (a)->d.len )

/* Basic types */
typedef uint8_t byte;
typedef struct iobuf_struct *iobuf_t;
typedef struct iobuf_struct *IOBUF;  /* Compatibility with gpg 1.4. */

/* Main iobuf structure */
struct iobuf_struct {
    int use;                /* Type of buffer */
    struct {
        byte *buf;          /* Data buffer */
        size_t start;       /* Start offset */
        size_t len;        /* Length of data */ 
        size_t size;       /* Total size of buffer */
    } d;
    
    int filter_eof;         /* EOF flag */
    int error;             /* Last error code */
    unsigned long nlimit;   /* Read limit */
    unsigned long nbytes;   /* Bytes processed */
    unsigned long ntotal;   /* Total bytes processed */
    int nofast;           /* Flag for slow path */
    
    /* Filter info */
    int (*filter)(void *opaque, int control,
                  iobuf_t chain, byte *buffer, size_t *len);
    void *filter_ov;       /* Filter private data */
    int filter_ov_owner;   /* True if we own filter data */
    
    iobuf_t chain;         /* Next filter in chain */
    
    int no;                /* Debug number */
    int subno;            /* Sub-number */
};

/* Core functions */
iobuf_t iobuf_alloc(int use, size_t bufsize);
iobuf_t iobuf_temp(void);
iobuf_t iobuf_temp_with_content(const char *buffer, size_t length);
int iobuf_close(iobuf_t iobuf);
int iobuf_cancel(iobuf_t iobuf);

int iobuf_push_filter(iobuf_t a,
                     int (*f)(void *opaque, int control,
                             iobuf_t chain, byte *buf, size_t *len),
                     void *ov);

int iobuf_pop_filter(iobuf_t a,
                     int (*f)(void *opaque, int control,
                             iobuf_t chain, byte *buf, size_t *len),
                     void *ov);

/* I/O functions */
int iobuf_readbyte(iobuf_t a);
int iobuf_read(iobuf_t a, void *buf, unsigned buflen);
int iobuf_writebyte(iobuf_t a, unsigned int c);
int iobuf_write(iobuf_t a, const void *buffer, unsigned int buflen);
int iobuf_write_temp(iobuf_t dest, iobuf_t source);

/* Buffer operations */
void iobuf_flush_temp(iobuf_t temp);
size_t iobuf_temp_to_buffer(iobuf_t a, byte *buffer, size_t buflen);

/* Control functions */
void iobuf_set_limit(iobuf_t a, unsigned long nlimit);
unsigned long iobuf_tell(iobuf_t a);
void iobuf_set_partial_block_mode(iobuf_t a, size_t len);
int iobuf_flush(iobuf_t a);
static int filter_flush(iobuf_t a);
static int block_filter(void *opaque, int control,
                       iobuf_t chain, byte *buf, size_t *len);
void
iobuf_set_partial_body_length_mode (iobuf_t a, size_t len);
iobuf_t iobuf_create (const char *fname, int mode700);
/* Convenience macros */
#define iobuf_get(a)  \
    (((a)->nofast || (a)->d.start >= (a)->d.len) ? \
     iobuf_readbyte((a)) : ((a)->nbytes++, (a)->d.buf[(a)->d.start++]))

#define iobuf_get_noeof(a)    (iobuf_get((a)) & 0xff)
#define iobuf_put(a,c)        iobuf_writebyte(a,c)

#endif /* IOBUF_H */