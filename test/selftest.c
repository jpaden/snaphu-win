/*
 * selftest.c - makes a test interferogram for SNAPHU and checks the result
 *
 * Usage:
 *   selftest make  wrapped.bin     write the test interferogram
 *   selftest check unwrapped.bin   compare the SNAPHU output to the truth
 *
 * The true phase is a smooth hill, 4 cycles high, on top of a gentle ramp.
 * It is smooth enough that there are no residues, so a correct unwrap is
 * the true phase plus one constant.
 *
 * File formats (these are the SNAPHU defaults):
 *   Input, COMPLEX_DATA: the lines are written one after another. Each
 *   sample is two 32 bit floats: the real part and then the imaginary part.
 *   Output, ALT_LINE_DATA: for each line, one line of magnitude as 32 bit
 *   floats and then one line of unwrapped phase (radians) as 32 bit floats.
 *
 * This file is part of snaphu-win and is not part of SNAPHU.
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_LINES 200    /* number of lines in the interferogram */
#define LINE_LENGTH 150  /* number of samples in each line */
#define TWO_PI 6.283185307179586

/* Largest allowed difference from the true phase (radians) */
#define TOLERANCE 1e-3

/* True (unwrapped) phase in radians of the sample at this line and sample */
static double true_phase(int line, int sample)
{
  double dl = (line - 0.5 * NUM_LINES) / (0.2 * NUM_LINES);
  double ds = (sample - 0.5 * LINE_LENGTH) / (0.2 * LINE_LENGTH);
  double hill = 4.0 * exp(-0.5 * (dl * dl + ds * ds));
  double ramp = 0.01 * sample - 0.005 * line;
  return TWO_PI * (hill + ramp);
}

static int make(const char *fn)
{
  FILE *fid = fopen(fn, "wb");
  if (fid == NULL) {
    fprintf(stderr, "ERROR: cannot open %s for writing\n", fn);
    return 1;
  }
  for (int line = 0; line < NUM_LINES; line++) {
    for (int sample = 0; sample < LINE_LENGTH; sample++) {
      double phase = true_phase(line, sample);
      float re_im[2] = {(float)cos(phase), (float)sin(phase)};
      fwrite(re_im, sizeof(float), 2, fid);
    }
  }
  fclose(fid);
  printf("Wrote %s: %d lines, %d samples in each line\n", fn, NUM_LINES, LINE_LENGTH);
  return 0;
}

static int check(const char *fn)
{
  static float magnitude[LINE_LENGTH];
  static float phase[LINE_LENGTH];
  double offset = 0;
  double max_error = 0;

  FILE *fid = fopen(fn, "rb");
  if (fid == NULL) {
    fprintf(stderr, "FAIL: cannot open %s. SNAPHU did not write its output.\n", fn);
    return 1;
  }
  for (int line = 0; line < NUM_LINES; line++) {
    if (fread(magnitude, sizeof(float), LINE_LENGTH, fid) != LINE_LENGTH
        || fread(phase, sizeof(float), LINE_LENGTH, fid) != LINE_LENGTH) {
      fprintf(stderr, "FAIL: %s is too short\n", fn);
      fclose(fid);
      return 1;
    }
    for (int sample = 0; sample < LINE_LENGTH; sample++) {
      /* Unwrapping only finds the phase to within a constant, so the first
       * sample is used to find that constant. */
      if (line == 0 && sample == 0) {
        offset = phase[0] - true_phase(0, 0);
      }
      double error = fabs(phase[sample] - offset - true_phase(line, sample));
      if (error > max_error) {
        max_error = error;
      }
    }
  }
  fclose(fid);

  printf("Largest difference from the true phase: %.2e radians (allowed: %.0e)\n",
         max_error, TOLERANCE);
  if (max_error > TOLERANCE) {
    printf("FAIL\n");
    return 1;
  }
  printf("PASS\n");
  return 0;
}

int main(int argc, char *argv[])
{
  if (argc == 3 && strcmp(argv[1], "make") == 0) {
    return make(argv[2]);
  }
  if (argc == 3 && strcmp(argv[1], "check") == 0) {
    return check(argv[2]);
  }
  fprintf(stderr, "Usage: selftest make wrapped.bin | selftest check unwrapped.bin\n");
  return 2;
}
