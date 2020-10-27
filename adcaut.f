      SUBROUTINE ADCAUT(ZTE,ZNE,ZTA,ZNA)
C
C*******************************************************
C     PRINTOUT DETAILED DATA INTO FILE 'adcaux.txt'
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)
C
      COMMON / ADELEC / RCLION(100), RRAREC(100), RDIREC(100),
     &                  CIZLOS(100), RADRRC(100), RADDRC(100),
     &                  RADCLX(100), RADBRM(100)
C
      COMMON / ADNEUT / RCXREC(100), RADBCX(100)
C
      COMMON / ADPARM / LADEN, LADTIP, LTIPOK, LECI, LECIOK
C
      COMMON / ADDIEL / CDNN(100), CDNM(100), 
     &                  YHNNA, YHNNB, YHNNC, YHNMA, YHNMB, YHNMC,
     &                  LDRMLT
C
      COMMON / ADCEQ / CEAVGZ, CEAVGZ2, CERAD, CELOS,
     &                 CEFRAC(100),TOTREC(100),TOTION(100), 
     &                 TOTRAD(100)
C
      COMMON / ADCXXC / ANNEUT(5), VNEUT(5), 
     &                  NCXB, NCXOPT, NCXERR, IVUNIT
C
      DIMENSION IHMOMY(2), IHTIP(2), IHVU(2), IHXS(5), IHECI(3)
      CHARACTER*4 IHMOMY,IHTIP*3,IHVU,IHXS,IHECI
C
      IOUT=10
C
      IHMOMY(1) = 'MAYR'
      IHMOMY(2) = 'MORE'
      IHTIP(1) = 'OUT'
      IHTIP(2) = '   '   
      IHVU(1) = 'CM/S'
      IHVU(2) = 'KV/A'
      IHXS(1) = 'OSAS'
      IHXS(2) = 'GJ  '
      IHXS(3) = 'OSCT'
      IHECI(1) = 'XSNQ'
      IHECI(2) = 'BFST'
      IHECI(3) = 'HYGR'
C
C
      OPEN(UNIT=IOUT,FILE='adcaux.txt')
C
C----PRINT HEADER
C
      WRITE(IOUT,102)
  102 FORMAT(/1X,'=================')
      WRITE(IOUT,100)
  100 FORMAT(1X,'   ADC results')
      WRITE(IOUT,101)
  101 FORMAT(1X,'================='/)
C
C-----PRINT INPUT ATOMIC DATA
C
      WRITE(IOUT,200)
  200 FORMAT(1X,'MAYER(0) OR MORE(1) ENERGIES')
      WRITE(IOUT,*) LADEN
C
      WRITE(IOUT,201)
  201 FORMAT(1X,'ENERGY TAB ALLOWED(YES=1)')
      WRITE(IOUT,*) LADTIP
C
      WRITE(IOUT,202)
  202 FORMAT(1X,'IONIZATION RATES (XSNQ=1, BELFAST=2, YOUNGER=3)')
      WRITE(IOUT,*) LECI
C
      WRITE(IOUT,205)
  205 FORMAT(1X,'DIELECTRONIC MULTIPLIER (1=1.0, 2=HAHN,',
     &          ' 3=INPUT HAHN)')
      WRITE(IOUT,*) LDRMLT
C
      IF(LDRMLT .EQ. 1) GO TO 220
      WRITE(IOUT,210)
  210 FORMAT(1X,'HAHN CONSTANTS (NN A,B,C; NM A,B,C)')
      WRITE(IOUT,211)YHNNA,YHNNB,YHNNC,YHNMA,YHNMB,YHNMC
  211 FORMAT(1X,3(1PE8.2,1X),3X,3(1PE8.2,1X))
C
C----PRINT NEUTRAL BEAM INPUT DATA
C
  220 CONTINUE
      IF(NCXB .LE. 0) WRITE(IOUT,92)
   92 FORMAT(6X,'***** NO BEAMS *****')
      IF(NCXB .GT. 0) WRITE(IOUT,90)NCXB
   90 FORMAT(1X,'NUMBER OF NEUTRAL BEAM COMPONENTS (MAX 5)'/,I3)

      IF(NCXB .GT. 0) WRITE(IOUT,94)NCXOPT
   94 FORMAT(1X,'X-S OPTION (1=OSAS,2=GJ,3=OSCT),'/,I3)
      IF(NCXB .GT. 0) WRITE(IOUT,98)IVUNIT
   98 FORMAT(1X,'ENERGY UNITS (1=CM/S,2=KEV/AMU)'/,I3)

      IF(NCXB .GT. 0) WRITE(IOUT,95)
   95 FORMAT(1X,'ARRAY OF NEUTRAL DENSITIES (CM-3)')
      IF(NCXB .GT. 0) WRITE(IOUT,93) (ANNEUT(J),J=1,NCXB)
   93 FORMAT(1PE9.2)
      IF(NCXB .GT. 0) WRITE(IOUT,96)
   96 FORMAT(1X,'ARRAY OF NEUTRAL ENERGIES/VELOCITIES')
      IF(NCXB .GT. 0) WRITE(IOUT,97) (VNEUT(J), J=1,NCXB)
   97 FORMAT(1PE9.2)
C
      WRITE(IOUT,91)
   91 FORMAT(/1X,10('-------'),'-')
C
C----PRINT PLASMA PARAMETERS
C
      WRITE(IOUT,309) ZTE
  309 FORMAT(/1X,'ELECTRON TEMPERATURE=',1PE10.2,' eV')
      WRITE(IOUT,308) ZNE
  308 FORMAT(/1X,'ELECTRON DENSITY=',1PE10.2,' cm-3')
C
C----PRINT ATOMIC STRUCTURE DATA
C
      WRITE(IOUT,307)NUCZ
  307 FORMAT(/1X,'Z =',I3)
C
      WRITE(IOUT,91)
C
C----PRINT RATE DATA
C
      WRITE(IOUT,112)
  112 FORMAT(/,1X,'SPC',2X,'VS',2X,'VSP',3X,'ION POT',4X,'RCLION',
     & 5X,'RRAREC',5X,'RDIREC',5X,'RCXREC',5X,'TOTREC'/)
C
      DO 10 JQ = 1 , NSPC
C
      IVALNC = NVALNC(JQ)
      ZCLION = RCLION(JQ) / ZNE
      ZRAREC = RRAREC(JQ) / ZNE
      ZDIREC = RDIREC(JQ) / ZNE
      ZCXREC = RCXREC(JQ) / ZNE
C
      ZRTOT  = RRAREC(JQ) + RDIREC(JQ) + RCXREC(JQ)
      ZRTOT  = ZRTOT / ZNE
C
      WRITE(IOUT,3)JQ,IVALNC,APN(JQ,IVALNC),EIN(JQ,IVALNC),
     & RCLION(JQ),RRAREC(JQ),RDIREC(JQ),RCXREC(JQ),TOTREC(JQ)
    3 FORMAT(1X,I2,I5,F5.0,F9.3,1X,1P5E11.2)
C
      WRITE(IOUT,5) ZCLION, ZRAREC, ZDIREC, ZCXREC, ZRTOT
    5 FORMAT(1X,23X,5(' (',1PE8.2')'))
C
   10 CONTINUE
C
      WRITE(IOUT,12)
   12 FORMAT(/)
C
C-----PRINTOUT NORMALIZED SPECIES FRACTIONS AND RADIATION RATES
C
      WRITE(IOUT,58)
   58 FORMAT(/1X,'SPC',2X,'CEQ FRAC',2X,'RADRRC',5X,'RADDRC',
     &       5X,'RADCLX',5X,'RADBRM',5X,'RADBCX',6X,'TOTAL'/)
C
      DO 60 JQ = 1 , NSPC
C
      ZRDRRC = RADRRC(JQ) / ZNE
      ZRDDRC = RADDRC(JQ) / ZNE
      ZRDCLX = RADCLX(JQ) / ZNE
      ZRDBRM = RADBRM(JQ) / ZNE
      ZRDBCX = RADBCX(JQ) / ZNE
C
      ZTRAD = RADRRC(JQ) + RADDRC(JQ) + RADCLX(JQ) + 
     &        RADBRM(JQ) + RADBCX(JQ)
      ZTRAD = ZTRAD / ZNE
C
      WRITE(IOUT,66)JQ,CEFRAC(JQ),RADRRC(JQ),RADDRC(JQ),
     & RADCLX(JQ),RADBRM(JQ),RADBCX(JQ),TOTRAD(JQ)
   66 FORMAT(1X,I2,1PE10.2,1PE10.2,1P5E11.2)
C
      WRITE(IOUT,68) ZRDRRC, ZRDDRC, ZRDCLX, ZRDBRM, ZRDBCX, ZTRAD
   68 FORMAT(1X,12X,6(' (',1PE8.2,')') )
C
   60 CONTINUE
C
C
C-----PRINT AVERAGED DATA
C
      WRITE(IOUT,75) CEAVGZ
   75 FORMAT(/6X,'<Z> =',1PE9.2)
      WRITE(IOUT,76) CEAVGZ2
   76 FORMAT(/6X,'<Z2>=',1PE9.2)
      WRITE(IOUT,77) CERAD
   77 FORMAT(/6X,'CRAD=',1PE9.2,' W-cm3')
      WRITE(IOUT,78) CERAD*ZNE
   78 FORMAT(/6X,'RAD =',1PE9.2,' W/ION')
      WRITE(IOUT,79) CELOS
   79 FORMAT(/6X,'CELS=',1PE9.2,' W-cm3')
      WRITE(IOUT,74) CELOS*ZNE
   74 FORMAT(/6X,'ELOS=',1PE9.2,' W/ION'/)
C
C
      CLOSE(UNIT=IOUT)
C
C
      RETURN
      END



      SUBROUTINE ADCAUT1(ZTE,ZNE,ZTA,ZNA)
C
C*******************************************************
C     PRINTOUT DETAILED DATA INTO FILE 'adcaux1.txt'
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      INTEGER IOUT
C
      OPEN(UNIT=IOUT,FILE='adcaux1.txt')

      CALL ADCAUTU(IOUT,ZTE,ZNE)
C
      CLOSE(UNIT=IOUT)
C
      RETURN
      END



      SUBROUTINE ADCAUTU(IOUT,ZTE,ZNE)
C
C*******************************************************
C     PRINTOUT DETAILED DATA TO DESIRED UNIT
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      CALL ADCAUTH(IOUT)
      CALL ADCAUTI(IOUT)
      CALL ADCAUTP(IOUT,ZTE,ZNE)
      CALL ADCAUTR(IOUT,ZTE,ZNE)
      CALL ADCAUTD(IOUT,ZTE,ZNE)
C
      RETURN
      END


      SUBROUTINE ADCAUTH(IOUT)
C
C*******************************************************
C       PRINTOUT ADC HEADER
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
C
C----PRINT HEADER
C
      WRITE(IOUT,102)
  102 FORMAT(/1X,'=================')
      WRITE(IOUT,100)
  100 FORMAT(1X,'   ADC results')
      WRITE(IOUT,101)
  101 FORMAT(1X,'================='/)
C
C
      RETURN
      END



      SUBROUTINE ADCAUTI(IOUT)
C
C*******************************************************
C       PRINTOUT INPUT ATOMIC DATA
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)
C
      COMMON / ADPARM / LADEN, LADTIP, LTIPOK, LECI, LECIOK
C
      COMMON / ADDIEL / CDNN(100), CDNM(100), 
     &                  YHNNA, YHNNB, YHNNC, YHNMA, YHNMB, YHNMC,
     &                  LDRMLT
C
      COMMON / ADCXXC / ANNEUT(5), VNEUT(5), 
     &                  NCXB, NCXOPT, NCXERR, IVUNIT
C
      DIMENSION IHMOMY(2), IHTIP(2), IHVU(2), IHXS(5), IHECI(3)
      CHARACTER*4 IHMOMY,IHTIP*3,IHVU,IHXS,IHECI
C
      IHMOMY(1) = 'MAYR'
      IHMOMY(2) = 'MORE'
      IHTIP(1) = 'OUT'
      IHTIP(2) = '   '   
      IHVU(1) = 'CM/S'
      IHVU(2) = 'KV/A'
      IHXS(1) = 'OSAS'
      IHXS(2) = 'GJ  '
      IHXS(3) = 'OSCT'
      IHECI(1) = 'XSNQ'
      IHECI(2) = 'BFST'
      IHECI(3) = 'HYGR'
C
C-----PRINT INPUT ATOMIC DATA
C
      WRITE(IOUT,200)
  200 FORMAT(1X,'MAYER(0) OR MORE(1) ENERGIES')
      WRITE(IOUT,*) LADEN
C
      WRITE(IOUT,201)
  201 FORMAT(1X,'ENERGY TAB ALLOWED(YES=1)')
      WRITE(IOUT,*) LADTIP

      WRITE(IOUT,202)
  202 FORMAT(1X,'IONIZATION RATES (XSNQ=1, BELFAST=2, YOUNGER=3)')
      WRITE(IOUT,*) LECI
C
      WRITE(IOUT,205)
  205 FORMAT(1X,'DIELECTRONIC MULTIPLIER (1=1.0, 2=HAHN,',
     &          ' 3=INPUT HAHN)')
      WRITE(IOUT,*) LDRMLT
C
      IF(LDRMLT .EQ. 1) GO TO 220
      WRITE(IOUT,210)
  210 FORMAT(1X,'HAHN CONSTANTS (NN A,B,C; NM A,B,C)')
      WRITE(IOUT,211)YHNNA,YHNNB,YHNNC,YHNMA,YHNMB,YHNMC
  211 FORMAT(1X,3(1PE8.2,1X),3X,3(1PE8.2,1X))
C
C----PRINT NEUTRAL BEAM INPUT DATA
C
  220 CONTINUE
      IF(NCXB .LE. 0) WRITE(IOUT,92)
   92 FORMAT(6X,'***** NO BEAMS *****')
      IF(NCXB .GT. 0) WRITE(IOUT,90)NCXB
   90 FORMAT(1X,'NUMBER OF NEUTRAL BEAM COMPONENTS (MAX 5)'/,I3)

      IF(NCXB .GT. 0) WRITE(IOUT,94)NCXOPT
   94 FORMAT(1X,'X-S OPTION (1=OSAS,2=GJ,3=OSCT),'/,I3)
      IF(NCXB .GT. 0) WRITE(IOUT,98)IVUNIT
   98 FORMAT(1X,'ENERGY UNITS (1=CM/S,2=KEV/AMU)'/,I3)

      IF(NCXB .GT. 0) WRITE(IOUT,95)
   95 FORMAT(1X,'ARRAY OF NEUTRAL DENSITIES (CM-3)')
      IF(NCXB .GT. 0) WRITE(IOUT,93) (ANNEUT(J),J=1,NCXB)
   93 FORMAT(1PE9.2)
      IF(NCXB .GT. 0) WRITE(IOUT,96)
   96 FORMAT(1X,'ARRAY OF NEUTRAL ENERGIES/VELOCITIES')
      IF(NCXB .GT. 0) WRITE(IOUT,97) (VNEUT(J), J=1,NCXB)
   97 FORMAT(1PE9.2)

      RETURN
      END


      SUBROUTINE ADCAUTP(IOUT,ZTE,ZNE)
C
C*******************************************************
C         PRINTOUT  INPUT PARAMETERS
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)
C
      COMMON / ADCXXC / ANNEUT(5), VNEUT(5), 
     &                  NCXB, NCXOPT, NCXERR, IVUNIT
C
C
      WRITE(IOUT,91)
   91 FORMAT(/1X,10('-------'),'-')
C
C----PRINT PLASMA PARAMETERS
C
      WRITE(IOUT,309) ZTE
  309 FORMAT(/1X,'ELECTRON TEMPERATURE=',1PE10.2,' eV')
      WRITE(IOUT,308) ZNE
  308 FORMAT(/1X,'ELECTRON DENSITY=',1PE10.2,' cm-3')
C
C----PRINT ATOMIC STRUCTURE DATA
C
      WRITE(IOUT,307)NUCZ
  307 FORMAT(/1X,'Z =',I3)
C
      WRITE(IOUT,91)
C
      RETURN
      END



      SUBROUTINE ADCAUTR(IOUT,ZTE,ZNE)
C
C*******************************************************
C  PRINTOUT DETAILED DATA ON RATES TO DESIRED UNIT
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)
C
      COMMON / ADELEC / RCLION(100), RRAREC(100), RDIREC(100),
     &                  CIZLOS(100), RADRRC(100), RADDRC(100),
     &                  RADCLX(100), RADBRM(100)
      COMMON / ADNEUT / RCXREC(100), RADBCX(100)
C
      COMMON / ADCEQ / CEAVGZ, CEAVGZ2, CERAD, CELOS,
     &                 CEFRAC(100),TOTREC(100),TOTION(100), 
     &                 TOTRAD(100)
C
      COMMON / ADCXXC / ANNEUT(5), VNEUT(5), 
     &                  NCXB, NCXOPT, NCXERR, IVUNIT
C
C----PRINT RATE DATA
C
      WRITE(IOUT,112)
  112 FORMAT(/,1X,'SPC',2X,'VS',2X,'VSP',3X,'ION POT',4X,'RCLION',
     & 5X,'RRAREC',5X,'RDIREC',5X,'RCXREC',5X,'TOTREC'/)
C
      DO 10 JQ = 1 , NSPC
C
      IVALNC = NVALNC(JQ)
      ZCLION = RCLION(JQ) / ZNE
      ZRAREC = RRAREC(JQ) / ZNE
      ZDIREC = RDIREC(JQ) / ZNE
      ZCXREC = RCXREC(JQ) / ZNE
C
      ZRTOT  = RRAREC(JQ) + RDIREC(JQ) + RCXREC(JQ)
      ZRTOT  = ZRTOT / ZNE
C
      WRITE(IOUT,3)JQ,IVALNC,APN(JQ,IVALNC),EIN(JQ,IVALNC),
     & RCLION(JQ),RRAREC(JQ),RDIREC(JQ),RCXREC(JQ),TOTREC(JQ)
    3 FORMAT(1X,I2,I5,F5.0,F9.3,1X,1P5E11.2)
C
      WRITE(IOUT,5) ZCLION, ZRAREC, ZDIREC, ZCXREC, ZRTOT
    5 FORMAT(1X,23X,5(' (',1PE8.2')'))
C
   10 CONTINUE
C
      WRITE(IOUT,12)
   12 FORMAT(/)
C
C-----PRINTOUT NORMALIZED SPECIES FRACTIONS AND RADIATION RATES
C
      WRITE(IOUT,58)
   58 FORMAT(/1X,'SPC',2X,'CEQ FRAC',2X,'RADRRC',5X,'RADDRC',
     &       5X,'RADCLX',5X,'RADBRM',5X,'RADBCX',6X,'TOTAL'/)
C
      DO 60 JQ = 1 , NSPC
C
      ZRDRRC = RADRRC(JQ) / ZNE
      ZRDDRC = RADDRC(JQ) / ZNE
      ZRDCLX = RADCLX(JQ) / ZNE
      ZRDBRM = RADBRM(JQ) / ZNE
      ZRDBCX = RADBCX(JQ) / ZNE
C
      ZTRAD = RADRRC(JQ) + RADDRC(JQ) + RADCLX(JQ) + 
     &        RADBRM(JQ) + RADBCX(JQ)
      ZTRAD = ZTRAD / ZNE
C
      WRITE(IOUT,66)JQ,CEFRAC(JQ),RADRRC(JQ),RADDRC(JQ),
     & RADCLX(JQ),RADBRM(JQ),RADBCX(JQ),TOTRAD(JQ)
   66 FORMAT(1X,I2,1PE10.2,1PE10.2,1P5E11.2)
C
      WRITE(IOUT,68) ZRDRRC, ZRDDRC, ZRDCLX, ZRDBRM, ZRDBCX, ZTRAD
   68 FORMAT(1X,12X,6(' (',1PE8.2,')') )
C
   60 CONTINUE

      RETURN
      END


      SUBROUTINE ADCAUTD(IOUT,ZTE,ZNE)
C
C*******************************************************
C     PRINTOUT DISTRIBUTION AVERAGE DATA
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)

      COMMON / ADCEQ / CEAVGZ, CEAVGZ2, CERAD, CELOS,
     &                 CEFRAC(100),TOTREC(100),TOTION(100), 
     &                 TOTRAD(100)
C
      COMMON / ADCXXC / ANNEUT(5), VNEUT(5), 
     &                  NCXB, NCXOPT, NCXERR, IVUNIT
C
C-----PRINT AVERAGED DATA
C
      WRITE(IOUT,75) CEAVGZ
   75 FORMAT(/6X,'<Z> =',1PE9.2)
      WRITE(IOUT,76) CEAVGZ2
   76 FORMAT(/6X,'<Z2>=',1PE9.2)
      WRITE(IOUT,77) CERAD
   77 FORMAT(/6X,'CRAD=',1PE9.2,' W-cm3')
      WRITE(IOUT,78) CERAD*ZNE
   78 FORMAT(/6X,'RAD =',1PE9.2,' W/ION')
      WRITE(IOUT,79) CELOS
   79 FORMAT(/6X,'CELS=',1PE9.2,' W-cm3')
      WRITE(IOUT,74) CELOS*ZNE
   74 FORMAT(/6X,'ELOS=',1PE9.2,' W/ION'/)
C
C
      RETURN
      END



      SUBROUTINE ADCAUTS(IOUT,
     &                   ZS,Z2S,EZRAD,EZLOSS,ZDISTR)
C
C*******************************************************
C     PRINTOUT DISTRIBUTION AVERAGE DATA
C*******************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      IMPLICIT INTEGER (I-N)
C
      COMMON / ADSDAT / NUCZ, NSPC, APN(100,10), AQN(100,10),
     &                  NVALNC(100), SIGMA(10,10), QN(100,10),
     &                  EN(100,10), EIN(100,5), ENM(100,5,10),
     &                  FNM(100,5,10), FNN(100), ENN(100)

      COMMON / ADCEQ / CEAVGZ, CEAVGZ2, CERAD, CELOS,
     &                 CEFRAC(100),TOTREC(100),TOTION(100), 
     &                 TOTRAD(100)
C
      DIMENSION ZDISTR(*)
C
C-----PRINT AVERAGED DATA
C
      WRITE(IOUT,75) ZS
   75 FORMAT(/6X,'<Z> =',1PE9.2)
      WRITE(IOUT,76) Z2S
   76 FORMAT(/6X,'<Z2>=',1PE9.2)

      WRITE(IOUT,77) EZRAD
   77 FORMAT(/6X,'CERAD=',1PE9.2,' W-cm3')

      WRITE(IOUT,79) EZLOS
   79 FORMAT(/6X,'CELOS=',1PE9.2,' W-cm3')
C

      WRITE(IOUT,81)
   81 FORMAT(//1X,'-----NORMALIZED DISTRIBUTION',
     &  ' OVER IONIZATION STATES----')
      WRITE(IOUT,82)
   82 FORMAT(1X,'  Z ',9X,'  Ro')

      DO 100 I=1,NUCZ+1
      WRITE(IOUT,90) I-1, ZDISTR(I)
   90 FORMAT(/2X,I2,6X,1PE10.3)
  100 CONTINUE
C
      RETURN
      END

