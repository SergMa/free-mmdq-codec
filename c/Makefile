################################################################################
# MAKEFILE FOR FREE-MMDQ-CODEC TEST PROGRAMM                                   #
# Makefile                                                                     #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

PROJ = test

CROSS_COMPILE =
OUT     = out

HEADERS = mmdq_codec.h \
    my_fract.h \
    wave.h \
    mylog.h \
    types.h \
    g711super.h \
    _config.h \
    gsm.h \
    private.h \
    proto.h \
    toast.h \
    unproto.h \
    g72x.h \
    private.h \
    ima_adpcm.h

CFLAGS  = -O3 -Wall -Werror
DEFS    =

CFLAGS += -I.\
          -Ig726lib \
          -Iwave \
          -Iwave/ima_adpcm \
          -Iwave/gsmlib \
          -include "wave/gsmlib/_config.h"

LFLAGS = -lm

CC = $(CROSS_COMPILE)gcc $(CFLAGS) $(DEFS)
LD = $(CROSS_COMPILE)gcc $(LFLAGS)

all: $(OUT)/$(PROJ)

IMAADPCM_OBJS = $(OUT)/ima_adpcm.o

G726LIB_OBJS = $(OUT)/g72x.o \
	$(OUT)/g726_16.o \
	$(OUT)/g726_24.o \
	$(OUT)/g726_32.o \
	$(OUT)/g726_40.o

GSMLIB_OBJS = $(OUT)/code.o \
	$(OUT)/debug.o \
	$(OUT)/decode.o \
	$(OUT)/gsmadd.o \
	$(OUT)/gsm_create.o \
	$(OUT)/gsm_decode.o \
	$(OUT)/gsm_destroy.o \
	$(OUT)/gsm_encode.o \
	$(OUT)/gsm_explode.o \
	$(OUT)/gsm_implode.o \
	$(OUT)/gsm_option.o \
	$(OUT)/gsm_print.o \
	$(OUT)/long_term.o \
	$(OUT)/lpc.o \
	$(OUT)/preprocess.o \
	$(OUT)/rpe.o \
	$(OUT)/short_term.o \
	$(OUT)/table.o

WAVE_OBJS = $(GSMLIB_OBJS) \
	$(OUT)/g711super.o \
	$(OUT)/mylog.o \
	$(OUT)/wave.o

OBJS = $(WAVE_OBJS) \
	$(IMAADPCM_OBJS) \
	$(G726LIB_OBJS) \
	$(OUT)/mmdq_codec.o \
	$(OUT)/test.o

VPATH := wave wave/gsmlib wave/ima_adpcm g726lib

$(OUT)/%.o: %.c $(HEADERS)
	$(CC) -g -c $< -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o $@

$(OUT)/$(PROJ): $(OBJS) Makefile
	$(LD) $(OBJS) -o $@

clean:
	rm -f $(OUT)/*.o $(OUT)/*.d $(OUT)/test $(OUT)/*.bin $(OUT)/*.wav $(OUT)/*.log

.PHONY: all compile clean
