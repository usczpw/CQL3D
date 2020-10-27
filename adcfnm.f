      SUBROUTINE ADCFNM
C
C****************************************************************
C
C     INPUT : NUCZ, APN, AQN, NVALNC, ENM
C     OUTPUT : FNM, FNN, ENN
C
C     CALCULATES ABSORPTION OSCILLATOR STRENGTHS FOR TRANSITIONS
C     FROM SHELL IN TO SHELL IM FOR EACH SPECIES JQ AND STORES THEM
C     IN THE ARRAY FNM(JQ,IN,IM).  F(N,M) = (HYDROGENIC VALUE,
C     TABULATED FOR LOW N,M CALCULATED OTHERWISE) X (CORRECTION
C     FACTOR(S)) X (ELECTRON POPULATION OF SHELL IN) X (VACANY
C     FRACTION OF SHELL IM).
C
C     FOR N - N (E.G. DELTA N EQUAL ZERO) TRANSITIONS WE HAVE
C     F(N,N) = ANN + BNN/ZNUC, WHICH REPRESENTS A FIT TO THE
C     'EQUIVALENT' SINGLE TRANSITION USED TO MODEL ALL THE PHYSICAL
C     N - N TRANSITIONS.  ALSO COMPUTED IS E(N,N), THE 'EQUIVALENT'
C     ENERGY, E(N,N) = EPSILONNN * (ZCHG+1) ** ALPHANN.  THE ZANN, ETC.
C     ARRAYS ARE INDEXED BY THE TOTAL NUMBER OF BOUND ELECTRONS
C     IN THEIR ELECTRONIC CONFIGURATIONS (SEE REFERENCE (1)).
C
C     NOTE THAT HERE, AS IN OTHER ROUTINES, THE FILLING OF SHELLS
C     IN SIMPLE ASCENDING ORDER IS ASSUMED BOTH EXPLICITLY
C     (E.G., IN THE APN ARRAY CONTENTS) AS WELL AS IMPLICITY (THROUGH
C     THE USE OF NVALNC, ETC.).  ALSO, THE ANN, BNN, ETC.
C     COEFFICIENTS ARE DEFINED SPECIFICALLY FOR SUCH STATES.
C
C
C     REFERENCES:
C     1) POST ET AL., PPPL-1352 (WITH CORRECTIONS)
C     2) GRASBERGER, XSNQ - TOKAMAK MEMORANDUM #4, 7/29/76
C     3) GRASBERGER, XSNQ - TOKAMAK MEMORANDUM #10, 1/5/77
C     4) LOKKE & GRASBERGER, 'XSNQ-U A NON-LTE EMISSION AND
C        ABSORPTION COEFFICIENT SUBROUTINE', LLL REPORT UCRL-52276
C     5) MERTS ET AL., 'THE CALCULATED POWER OUTPUT FROM
C        A THIN IRON-SEEDED PLASMA', LOS ALAMOS REPORT LA-6220-MS
C     6) XSNQ FORTRAN LISTING
C
C********************************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)
C
C
      COMMON / FNMDAT / ZANN(60), ZBNN(60), ZEPSNN(60), ZALPNN(60),
     &          ZY0(10), ZY1(10), ZY2(10)
C
C
      DATA (ZANN(J),J=1,60) / 0., 0.,
     1 -.02, -.01, -.04, .04, -.01, -.01, .01, 0.,
     2  .01, .1, .25, .17, .08, -.02, -.14, -.27,
     3 -.29, -.3, -.3, -.29, -.27, -.24, -.2, -.14,
     4 -.08, 0., .97, 1.96, 1.92, 1.89, 1.86, 1.83,
     5 1.78, 1.73, 1.41, 1.05, .674, .261, -.167,
     6 -.637, -1.14, -1.67, -2.26, -2.88, -2.9,
     7 -2.83, -2.72, -2.61, -2.45, -2.27, -2.05, -1.81,
     8 -1.55, -1.25, -.94, -.63, -.31, 0. /
C
C
      DATA (ZBNN(J),J=1,60) / 0., 0.,
     1 2., 4.33, 4.68, 3.6, 2.85, 2.4, 1.3, 0.,
     2 10.5, 20., 16.4, 24.7, 34.1, 44.8, 56.8, 70.3,
     3 68.6, 65.8, 61.9, 56.9, 50.7, 45.5, 34.4,
     4 24.2, 12.8, 0., -25.8, -53.1, -28.1, -2.97,
     5 23., 50.3, 79.1, 109.2, 141.7, 176., 213.9,
     6 256.6, 299.6, 348.2, 400.5, 456.6, 518.1,
     7 584.0, 571.9, 550.7, 524.9, 496.8, 463.4,
     8 427., 385.3, 339.8, 291.3, 237.4, 181.3, 122.9,
     9 62.2, 0. /
C
C
      DATA (ZEPSNN(J),J=1,28) / 0., 0.,
     1 2.04E-3, 4.49E-3, 6.8E-3, 8.16E-3, 6.80E-3,
     2 1.06E-2, 1.31E-2, 0., 2.3E-3, 3.88E-3,
     3 5.71E-3, 5.44E-3, 8.16E-3, 6.8E-3, 8.3E-3,
     4 4.32E-3, 5.11E-3, 6.04E-3, 7.08E-3,
     5 8.12E-3, 9.69E-3, 1.13E-2, 1.37E-2, 1.49E-2,
     6 1.71E-2, 0. /
C
      DATA (ZEPSNN(J),J=29,60) / 1.52E-5, 1.93E-5,
     1 5.62E-5, 1.20E-4, 2.13E-4, 3.34E-4, 4.66E-4,
     2 6.66E-4, 9.10E-4, 1.25E-3, 1.69E-3, 1.98E-3,
     3 3.03E-3, 3.92E-3, 5.19E-3, 6.40E-3, 8.05E-3,
     4 9.80E-3, 1.08E-2, 1.19E-2, 1.32E-2, 1.47E-2,
     5 1.59E-2, 1.81E-2, 1.92E-2, 2.10E-2, 2.33E-2,
     6 2.57E-2, 2.82E-2, 3.10E-2, 3.43E-2, 0. /
C
C
      DATA (ZALPNN(J),J=1,60) / 1.0, 1.0,
     1 1.0, .93, .86, .80, .87, .77, .77, 1.0,
     2 .99, .90, .83, .87, .77, .82, .79, 1.06,
     3 1.03, 1., .97, .94, .91, .88, .85,
     4 .83, .80, 1.0, 2.46, 2.4, 2.14, 1.96,
     5 1.83, 1.72, 1.64, 1.57, 1.49, 1.41, 1.34,
     6 1.30, 1.19, 1.13, 1.06, 1.01, .95, .91,
     7 .89, .87, .85, .83, .82, .80, .78, .76,
     8 .74, .72, .70, .68, .66, 1.0 /
C
C
      DATA (ZY0(J),J=1,10) / 1.0, .511, .400, 7*.230 /
C
      DATA (ZY1(J),J=1,10) / 0., .116, .0228, 7*.00844 /
C
      DATA (ZY2(J),J=1,10) / 0., -.00689, .000596, 7*.000488 /
C
C
C
C     ZERO OSCILLATOR STRENGTH ARRAYS AND ENN ARRAY
C
      DO 1 JQ = 1 , 100
      FNN(JQ) = 0.
      ENN(JQ) = 0.
      DO 1 JN = 1 , 5
      DO 1 JM = 1 , 10
    1 FNM(JQ,JN,JM) = 0.
C
      ZNUC = DBLE ( NUCZ )
C
C
C     ******************************************************
C     ***** LOOP FOR ALL SPECIES EXCEPT FULLY STRIPPED *****
C     ******************************************************
C
C
      DO 100 JQ = 1 , NUCZ
C
      ZCHG = DBLE(JQ-1)
      IBOUND = NUCZ - JQ + 1
      IVALNC = NVALNC(JQ)
C
C
C     ********** CALCULATE F(N,M) ( M > N ) **********
C
C
C     BEGIN BY EVALUTING HYDROGENIC F(N,M) EQUATION, WITH
C     EXPLICIT VALUES SUBSTITUTED FOR N < 5, M <= 5.
C
C
      DO 10 JN = 1 , IVALNC
      IIJM = MAX0 ( JN + 1 , IVALNC )
      ZN = DBLE(JN)
C
      DO 10 JM = IIJM , 10
      ZM = DBLE(JM)
      FNM(JQ,JN,JM) = 1.96 * ZN * ( ( ZM/(ZM*ZM - ZN*ZN) )**3 )
   10 CONTINUE
C
C     SUBSTITUTE TABLED VALUES FOR LOW N , M AS PER REF #4
C
      FNM(JQ,1,2) = 0.4161
      FNM(JQ,1,3) = 0.0792
      FNM(JQ,1,4) = 0.0290
      FNM(JQ,1,5) = 0.0139
      FNM(JQ,2,3) = 0.6370
      FNM(JQ,2,4) = 0.1190
      FNM(JQ,2,5) = 0.0443
      FNM(JQ,3,4) = 0.8408
      FNM(JQ,3,5) = 0.1499
      FNM(JQ,4,5) = 1.037
C
C     MODIFY NONZERO F(N,N+1) VALUES FOR N > 1 AS PER REF #3
C
      DO 20 J = 1 , 2
      JN = IVALNC + J - 2
      IF(JN .LE. 1) GO TO 20
      JM = JN + 1
      IF(AQN(JQ,JM) .EQ. 0.) GO TO 20
C
      ZNCHG = ZCHG + APN(JQ,JM)
      ZEHYDR = .0136 * ((ZNCHG+1.)**2) *
     &                   ( 1./DBLE(JN)**2 - 1./DBLE(JM)**2 )
      ZRATIO = ZEHYDR / ENM(JQ,JN,JM)
      IF(ZRATIO .GT. 1.0) ZRATIO = 1.0
      ZYNPN = ZY0(JN) + ZY1(JN) * APN(JQ,JN) + ZY2(JN) * APN(JQ,JN)**2
C
      FNM(JQ,JN,JM) = FNM(JQ,JN,JM) * ZRATIO * ZYNPN
C
   20 CONTINUE
C
C
C     MULTIPLY BY ELECTRON POPULATION OF SHELL N AND FRACTIONAL
C     VACANCY OF SHELL M
C
C
      DO 30 JN = 1 , 5
      DO 30 JM = 1 , 10
      FNM(JQ,JN,JM) = APN(JQ,JN) * AQN(JQ,JM) * FNM(JQ,JN,JM)
   30 CONTINUE
C
C
C
C     ***** CALCULATE N - N 'EFFECTIVE' OSCILLATOR STRENGTHS *****
C                   ***** AND TRANSITION ENERGIES *****
C
C
C
      INDEX = IBOUND
C     IF MORE THAN 60 BOUND ELECTRONS USE CONSTANTS FOR ION WITH
C     32 FEWER ELECTRONS
      IF(INDEX.GT.60)INDEX = INDEX - 32
      IF(INDEX.GT.60)INDEX = INDEX - 32
C
      FNN(JQ) = ZANN(INDEX) + ZBNN(INDEX) / ZNUC
C
      ENN(JQ) = ZEPSNN(INDEX) * (ZCHG + 1.)**ZALPNN(INDEX)
C
C
C
C
C     CHECK TO INSURE ALL F VALUES ARE POSITIVE
C
      IF(FNN(JQ) .GE. 0.) GO TO 40
      FNN(JQ) = 0.
      WRITE(10,900) JQ , IVALNC , IVALNC
  900 FORMAT(1X,26H***** NEGATIVE F VALUE AT ,3I4,6H *****)
   40 DO 41 JN = 1 , 5
      DO 41 JM = 1 , 10
      IF(FNM(JQ,JN,JM) .GE. 0.) GO TO 41
      FNM(JQ,JN,JM) = 0.
      WRITE(10,900) JQ , JN , JM
   41 CONTINUE
C
C     DIAGNOSTIC WRITE STATMENTS TO DISPLAY F VALUES
C
CW    WRITE(10,901)JQ,FNN(JQ),ENN(JQ)
CW  901 FORMAT(/1X,'SETFNM: JQ =',I3,'  FNN =',1PE9.2,'  ENN =',E9.2)
CW    WRITE(10,902)( JN,(FNM(JQ,JN,JM),JM=1,10),JN=1,5)
CW  902 FORMAT(1X,'JN =',I2,10F6.1)
C
C
C     *************** END OF JQ SPECIES LOOP ***************
C
C
  100 CONTINUE
C
      RETURN
      END