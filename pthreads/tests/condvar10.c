/*
 * File: condvar10.c
 *
 *
 * --------------------------------------------------------------------------
 *
 *      Pthreads-win32 - POSIX Threads Library for Win32
 *      Copyright(C) 1998 John E. Bossom
 *      Copyright(C) 1999,2005 Pthreads-win32 contributors
 * 
 *      Contact Email: rpj@callisto.canberra.edu.au
 * 
 *      The current list of contributors is contained
 *      in the file CONTRIBUTORS included with the source
 *      code distribution. The list can also be seen at the
 *      following World Wide Web location:
 *      http://sources.redhat.com/pthreads-win32/contributors.html
 * 
 *      This library is free software; you can redistribute it and/or
 *      modify it under the terms of the GNU Lesser General Public
 *      License as published by the Free Software Foundation; either
 *      version 2 of the License, or (at your option) any later version.
 * 
 *      This library is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *      Lesser General Public License for more details.
 * 
 *      You should have received a copy of the GNU Lesser General Public
 *      License along with this library in the file COPYING.LIB;
 *      if not, write to the Free Software Foundation, Inc.,
 *      59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 *
 * --------------------------------------------------------------------------
 *
 * Test Synopsis:
 * - Test timed wait on a CV for various ranges of timed intervals.
 *
 * Test Method (Validation or Falsification):
 * - Validation
 *
 * Requirements Tested:
 * - 
 *
 * Features Tested:
 * - 
 *
 * Cases Tested:
 * - 
 *
 * Description:
 * - Because the CV is never signaled, we expect the wait to time out.
 *
 * Environment:
 * -
 *
 * Input:
 * - None.
 *
 * Output:
 * - File name, Line number, and failed expression on failure.
 * - No output on success.
 *
 * Assumptions:
 * - 
 *
 * Pass Criteria:
 * - pthread_cond_timedwait returns ETIMEDOUT with reasonable wait times 
 *   for all intervals.
 * - Process returns zero exit status.
 *
 * Fail Criteria:
 * - pthread_cond_timedwait does not return ETIMEDOUT.
 * - pthread_cond_timedwait returns too soon.
 * - Process returns non-zero exit status.
 */

#define _WIN32_WINNT 0x400

#include "test.h"
#include <sys/timeb.h>

#include "../implement.h"

pthread_cond_t cnd;
pthread_mutex_t mtx;

HANDLE hEvent;

static const long NANOSEC_PER_SEC = 1000000000L;
static const long NANOSEC_PER_MILLISEC = 1000000L;
static const long MILLISEC_PER_SEC = 1000L;

int ms_sleep (int ms, int mode, int *slept)
{
   struct timespec abstime, starttime, elapsedtime;
   int elapsedms;
   
   *slept = 0;
   (void) pthread_win32_getabstime_np(&starttime, NULL);

   switch (mode) {
       case 0:
           abstime = starttime;
           abstime.tv_sec += ms / MILLISEC_PER_SEC;
           abstime.tv_nsec += (ms % MILLISEC_PER_SEC) * NANOSEC_PER_MILLISEC;
           while (abstime.tv_nsec >= NANOSEC_PER_SEC)
             {
                abstime.tv_nsec %= NANOSEC_PER_SEC;
                abstime.tv_sec += abstime.tv_nsec / NANOSEC_PER_SEC;
             }

           assert(pthread_mutex_lock(&mtx) == 0);

           *slept = (pthread_cond_timedwait(&cnd, &mtx, &abstime) == ETIMEDOUT);

           assert(pthread_mutex_unlock(&mtx) == 0);
           break;
       case 1:
           Sleep(ms);
           *slept = 1;
           break;
       case 2:
           if (WAIT_TIMEOUT == WaitForSingleObject(hEvent, ms))
             *slept = 1;
           break;
       }

   (void) pthread_win32_getabstime_np(&elapsedtime, NULL);

   if (elapsedtime.tv_nsec < starttime.tv_nsec)
     {
       elapsedtime.tv_sec -= 1;
       elapsedtime.tv_nsec += NANOSEC_PER_SEC;
     }
   elapsedtime.tv_nsec -= starttime.tv_nsec;
   elapsedtime.tv_sec -= starttime.tv_sec;
   elapsedms = (int)((elapsedtime.tv_sec * MILLISEC_PER_SEC) + (elapsedtime.tv_nsec + (NANOSEC_PER_MILLISEC/2)) / NANOSEC_PER_MILLISEC);
   return elapsedms;
}

long
delta_STRUCT_TIMER (PTW32_STRUCT_TIMEB *prevTime)
{
  PTW32_STRUCT_TIMEB currSysTime;

  /* get current system time */
  PTW32_FTIME(&currSysTime);
  if (currSysTime.millitm < prevTime->millitm)
    {
      currSysTime.millitm += (unsigned short)MILLISEC_PER_SEC;
      currSysTime.time -= 1;
    }
  return (long)(((currSysTime.time - prevTime->time) * MILLISEC_PER_SEC) + 
                (currSysTime.millitm - prevTime->millitm));
}

int sleep_test (int interval, int count)
{
  int i, mode;
  int total_time = 0;
  PTW32_STRUCT_TIMEB startSysTime;
  long elapsedms;

  for (mode=0; mode<3; mode++) {
    int tot_time = 0;
    int tot_slept = 0;

    PTW32_FTIME(&startSysTime);
    for (i=0; i<count; i++)
      {
        int slept;

        tot_time += ms_sleep(interval, mode, &slept);
        tot_slept += slept;
      }

    elapsedms = delta_STRUCT_TIMER(&startSysTime);
    fprintf (stderr, "Mode=%d, Interval=%d, count=%d\n", mode, interval, count);
    fprintf (stderr, "Slept=%d, Expected time %ld ms, Actual time: %ld, Total time reported: %d\n", tot_slept, (long)(interval * count), elapsedms, tot_time);
    total_time += tot_time;
    }

  return total_time >= (3 * (interval * count));
}

static TIMECAPS timers;

  void timer_exit (void)
{
timeEndPeriod (timers.wPeriodMin);  /* undo timeBeginPeriod effects */
}

int
main()
{
  assert(TIMERR_NOERROR == timeGetDevCaps (&timers, sizeof (timers)));
  assert(timers.wPeriodMin != 0);
  assert(TIMERR_NOERROR == timeBeginPeriod (timers.wPeriodMin));
  atexit (timer_exit);

  assert(pthread_cond_init(&cnd, NULL) == 0);

  assert(pthread_mutex_init(&mtx, NULL) == 0);

  assert(NULL != (hEvent = CreateEvent(NULL, FALSE, FALSE, NULL)));

  assert(sleep_test(1, 100));

  assert(sleep_test(5, 20));

  assert(sleep_test(5000, 1));

  assert(sleep_test(0, 100));

  {
  int result = pthread_cond_destroy(&cnd);
  if (result != 0)
    {
      fprintf(stderr, "Result = %s\n", error_string[result]);
      fprintf(stderr, "\tWaitersBlocked = %ld\n", cnd->nWaitersBlocked);
      fprintf(stderr, "\tWaitersGone = %ld\n", cnd->nWaitersGone);
      fprintf(stderr, "\tWaitersToUnblock = %ld\n", cnd->nWaitersToUnblock);
      fflush(stderr);
    }
  assert(result == 0);
  }

  return 0;
}
