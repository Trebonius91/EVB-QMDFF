!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   EVB-QMDFF - RPMD molecular dynamics and rate constant calculations on
!               black-box generated potential energy surfaces
!
!   Copyright (c) 2021 by Julien Steffen (steffen@pctc.uni-kiel.de)
!                         Stefan Grimme (grimme@thch.uni-bonn.de) (QMDFF code)
!
!   Permission is hereby granted, free of charge, to any person obtaining a
!   copy of this software and associated documentation files (the "Software"),
!   to deal in the Software without restriction, including without limitation
!   the rights to use, copy, modify, merge, publish, distribute, sublicense,
!   and/or sell copies of the Software, and to permit persons to whom the
!   Software is furnished to do so, subject to the following conditions:
!
!   The above copyright notice and this permission notice shall be included in
!   all copies or substantial portions of the Software.
!
!   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
!   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
!   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
!   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
!   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
!   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
!   DEALINGS IN THE SOFTWARE.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      subroutine egrad_h3(q,Natoms,Nbeads,V,dVdq,info)
      integer, intent(in) :: Natoms
      integer, intent(in) :: Nbeads
      double precision, intent(in) :: q(3,Natoms,Nbeads)
      double precision, intent(out) :: V(Nbeads)
      double precision, intent(out) :: dVdq(3,Natoms,Nbeads)

      double precision :: R(3), dVdr(3)
      double precision :: xAB, yAB, zAB, rAB
      double precision :: xAC, yAC, zAC, rAC
      double precision :: xBC, yBC, zBC, rBC
      integer k, info
	info = 0 
      do k = 1, Nbeads
              
        xAB = q(1,2,k) - q(1,1,k)
        yAB = q(2,2,k) - q(2,1,k)
        zAB = q(3,2,k) - q(3,1,k)
        rAB = sqrt(xAB * xAB + yAB * yAB + zAB * zAB)
        R(1) = rAB
        
        xAC = q(1,1,k) - q(1,3,k)
        yAC = q(2,1,k) - q(2,3,k)
        zAC = q(3,1,k) - q(3,3,k)
        rAC = sqrt(xAC * xAC + yAC * yAC + zAC * zAC)
        R(2) = rAC

        xBC = q(1,3,k) - q(1,2,k)
        yBC = q(2,3,k) - q(2,2,k)
        zBC = q(3,3,k) - q(3,2,k)
        rBC = sqrt(xBC * xBC + yBC * yBC + zBC * zBC)
        R(3) = rBC
        
        call pote(R, V(k), dVdr)
  
        dVdq(1,1,k) = dVdr(2) * xAC / rAC - dVdr(1) * xAB / rAB
        dVdq(2,1,k) = dVdr(2) * yAC / rAC - dVdr(1) * yAB / rAB
        dVdq(3,1,k) = dVdr(2) * zAC / rAC - dVdr(1) * zAB / rAB
        
        dVdq(1,2,k) = dVdr(1) * xAB / rAB - dVdr(3) * xBC / rBC
        dVdq(2,2,k) = dVdr(1) * yAB / rAB - dVdr(3) * yBC / rBC
        dVdq(3,2,k) = dVdr(1) * zAB / rAB - dVdr(3) * zBC / rBC

        dVdq(1,3,k) = dVdr(3) * xBC / rBC - dVdr(2) * xAC / rAC
        dVdq(2,3,k) = dVdr(3) * yBC / rBC - dVdr(2) * yAC / rAC
        dVdq(3,3,k) = dVdr(3) * zBC / rBC - dVdr(2) * zAC / rAC      
      end do
    
      end subroutine egrad_h3

      SUBROUTINE pote (R,pe,dpe)
C    *************************
C    *  B K M P 2     P E S  *   Implemented in carlon by L.B.
C    *************************
C
C CALCULATE TOTAL H3 POTENTIAL FROM ALL OF ITS PARTS
C IF (ID.GT.0) ALSO CALCULATE THE DV/DR DERIVATIVES
C ALL DISTANCES ARE IN BOHRS AND ALL ENERGIES ARE IN HARTREES
C
C FOR A DISCUSSION OF THIS SURFACE, SEE:
C    A.I.BOOTHROYD, W.J.KEOGH, P.G.MARTIN, M.R.PETERSON
C    JOURNAL OF CHEMICAL PHYSICS 95 PP4343-4359 (SEPT15/91)
C    AND JCP 104 PP 7139-7152 (MAY8/96)
C
C NOTE: THIS FILE CONTAINS PARAMETERS FOR A SURFACE REFITTED
C       ON JUNE21/95 TO A SET OF SEVERAL THOUSAND AB INITIO
C       POINTS.  THE '706' SURFACE PARAMETERS HAVE BEEN
C       COMMENTED OUT.  THE ROUTINE NAMES HAVE BEEN MODIFIED
C       SLIGHTLY (USUALLY A '95' APPENDED) SO THAT A PROGRAMME
C       COULD EASILY CALL AND COMPARE BOTH OF OUR SURFACES.
C
C NOTE: THE SURFACE PARAMETER VALUES AS PUBLISHED LEAD TO AN
C       ANOMOLOUSLY DEEP VAN DER WAALS WELL FOR A VERY COMPACT
C       H2 MOLECULE (SAY R=0.8).  AFTER THAT PAPER WAS SUBMITTED,
C       THIS PROBLEM WAS FIXED AND THE CORRECTED CBEND COEFFICIENTS
C       ARE USED IN THIS VERSION OF THE SURFACE (VERSION 706).
C       THE OLD COEFFICIENTS ARE STILL IN SUBR.VBCB BUT HAVE BEEN
C       COMMENTED OUT.
C
C ANY QUESTIONS/PROBLEMS/COMMENTS CONCERNING THIS PROGRAMME CAN BE
C ADDRESSED TO :    WKEOGH@ALCHEMY.CHEM.UTORONTO.CA
C (IF NECESSARY, VIA   BOOTHROY@CITA.UTORONTO.CA    BOOTHROY@UTORDOP.BITNET
C                 OR   PGMARTIN@CITA.UTORONTO.CA    PGMARTIN@UTORDOP.BITNET )
C
C VERSION:
C APR12/95 ... PARAMETERS FOR SURFACE850308 ADDED
C JUL27/91 ... SURF706D.OUT CBEND VALUES PUT IN
C----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      dimension R(3),DPE(3)
c     DIMENSION R(3)
      DIMENSION DVLON(3),DVAS(3),DVBNDA(3),DVBNDB(3),
     .          DCAL(3), DCAS(3),DCBNDA(3),DCBNDB(3)
      DIMENSION VB(2,25),CB(2,25)
C     DIMENSION VBP(2,25),CBP(2,25)
C     DIMENSION DB1A(3),DB1B(3)
      DIMENSION DT(3),T(3)
C     DIMENSION DB2(3),DB3(6),EXPASS(4)
      IPR = 0
cC
c      R(1)=RAB 
c      R(2)=RBC 
c      R(3)=RAC 
c     print*,r(1),r(2),r(3),rab,rbc,rac
C
c      print*,r(1),r(2),r(3)
      CALL CHGEOM(R,IVALID)
      IF(IVALID.LT.1)THEN
         VTOT   = 99.0
         DVTOT1 = 0.D0
         DVTOT2 = 0.D0
         DVTOT3 = 0.D0
         WRITE(6,6999) VTOT,DVTOT1,DVTOT2,DVTOT3
         RETURN
      END IF
 6999 FORMAT('INVALID GEOMETRY, V,DV=',4F8.2)
C
C
C  ZERO EVERYTHING TO AVOID ANY 'FUNNY' VALUES:
      VLON  = 0.D0
      VAS   = 0.D0
      VBNDA = 0.D0
      VBNDB = 0.D0
      CAL   = 0.D0
      CAS   = 0.D0
      CBNDA = 0.D0
      CBNDB = 0.D0
      DO I=1,3
         DVLON(I) = 0.D0
         DVAS(I)  = 0.D0
         DVBNDA(I)= 0.D0
         DVBNDB(I)= 0.D0
         DCAL(I)  = 0.D0
         DCAS(I)  = 0.D0
         DCBNDA(I)= 0.D0
         DCBNDB(I)= 0.D0
      END DO
C  ZERO THE VB AND CB ARRAYS (USED ONLY FOR NUMERICAL DERIVATIVES)
      DO I=1,25
         VB(1,I) = 0.D0
         VB(2,I) = 0.D0
         CB(1,I) = 0.D0
         CB(2,I) = 0.D0
      END DO
      CALL H3LOND95( R, VLON, DVLON )
      CALL VASCAL95( R, VAS, DVAS )
C    NOW DO ANY CORRECTIONS REQUIRED FOR COMPACT GEOMETRIES:
      CALL COMPAC95(R,ICOMPC,T,DT)
C    OCT.3/90 COMPACT ROUTINES ONLY CALLED FOR COMPACT GEOMETRIES:
      IF(ICOMPC.GE.1)THEN
         CALL CSYM95  ( R, CAL, DCAL )
         CALL CASYM95 ( R, CAS, DCAS,  1 ,T,DT)
      END IF
      CALL VBCB95(R,ICOMPC,T,DT,IPR,
     .          VBNDA,VBNDB,DVBNDA,DVBNDB,
     .          CBNDA,CBNDB,DCBNDA,DCBNDB)
C    ADD UP THE VARIOUS PARTS OF THE POTENTIAL:
      VTOT = VLON + VAS + VBNDA + VBNDB + CAL + CAS + CBNDA + CBNDB
      VTOT=VTOT
	PE=VTOT
C    ADD UP THE VARIOUS PARTS OF THE DERIVATIVE:
      DVTOT1 =   DVLON(1) + DVAS(1) + DVBNDA(1) + DVBNDB(1)
     .           +  DCAL(1) + DCAS(1) + DCBNDA(1) + DCBNDB(1)
      DVTOT2 =   DVLON(2) + DVAS(2) + DVBNDA(2) + DVBNDB(2)
     .           +  DCAL(2) + DCAS(2) + DCBNDA(2) + DCBNDB(2)
      DVTOT3 =   DVLON(3) + DVAS(3) + DVBNDA(3) + DVBNDB(3)
     .           +  DCAL(3) + DCAS(3) + DCBNDA(3) + DCBNDB(3)

	DPE(1)=DVTOT1
	DPE(2)=DVTOT2
	DPE(3)=DVTOT3
C
      IF(IPR.GT.0) THEN
          WRITE(7,*)
          WRITE(7,*) 'H3TOT ENTER --------------------------------'
          WRITE(7,7000) R,ICOMPC,VTOT,
     .             VLON,VAS,CAL,CAS,VBNDA,VBNDB,CBNDA,CBNDB
          IF(IPR.GT.1)THEN
                   WRITE(7,7100) DVTOT1,DVTOT2,DVTOT3,
     1                           DVLON,DVAS,DVBNDA,DVBNDB,
     .                           DCAL,DCAS,DCBNDA,DCBNDB
          END IF
          WRITE(7,7400) (VB(1,I),I=1,5),(VB(2,I),I=1,5)
          WRITE(7,7500) (CB(1,I),I=1,9),(CB(2,I),I=1,9)
          WRITE(7,7999) VBNDA,VBNDB,CBNDA,CBNDB,
     .                  DVBNDA,DVBNDB,DCBNDA,DCBNDB
          WRITE(7,*) 'EXITING SUBR.H3TOT'
          WRITE(7,*) 'H3TOT EXIT ---------------------------------'
      END IF
      RETURN
 7400 FORMAT('VBA VALUES: ',5(1X,G12.6),/,'VBB VALUES: ',5(1X,G12.6))
 7500 FORMAT('CBA VALUES: ',3(1X,F16.8),/,
     .       '            ',3(1X,F16.8),/,
     .       '            ',3(1X,F16.8),/,
     .       'CBB VALUES: ',3(1X,F16.8),/,
     .       '            ',3(1X,F16.8),/,
     .       '            ',3(1X,F16.8))
 7000 FORMAT(5X,'    R =',3(1X,F16.10),' ICOMPAC = ',I1,/,
     .       5X,'VTOT  = ',F18.12,/,
     .       5X,'VLON  = ',F18.12,'       VAS   = ',G18.12,/,
     .       5X,'CAL   = ',G18.12,'       CAS   = ',G18.12,/,
     .       5X,'VBNDA = ',G18.12,'       VBNDB = ',G18.12,/,
     .       5X,'CBNDA = ',G18.12,'       CBNDB = ',G18.12)
 7100 FORMAT(' DVTOT   = ',3(1X,G18.12),/,
     .       ' DVLON   = ',3(1X,G18.12),/,
     .       ' DVAS    = ',3(1X,G18.12),/,
     .       ' DVBNDA  = ',3(1X,G18.12),/,
     .       ' DVBNDB  = ',3(1X,G18.12),/,
     .       ' DCAL    = ',3(1X,G18.12),/,
     .       ' DCAS    = ',3(1X,G18.12),/,
     .       ' DCBNDA  = ',3(1X,G18.12),/,
     .       ' DCBNDB  = ',3(1X,G18.12))
 7750 FORMAT(3(1X,G16.10))
 7751 FORMAT(/,3(1X,G16.10))
 7999 FORMAT('   VBNDA        VBNDB        CBNDA        CBNDB ',/,
     .        4(E12.6,2X),/,
     .       'DVBNDA: ',3(E16.10,1X),/,
     .       'DVBNDB: ',3(E16.10,1X),/,
     .       'DCBNDA: ',3(E16.10,1X),/,
     .       'DCBNDB: ',3(E16.10,1X))
      END
C
      SUBROUTINE TRIPLET95(R,E3,ID)
C--------------------------------------------------------------------
C APR12/95 SURFACE950308 VALUES ADDED
C OCT04/90 SURFACE626 VALUES ADDED
C  H2 TRIPLET CURVE AND DERIVATIVES:
C  CALCULATES TRIPLET POTENTIAL AND FIRST DERIVATIVE
C  USES TRUHLAR HOROWITZ EQUATION WITH OUR EXTENSION
C  USES THE JOHNSON CORRECTION AT SHORT DISTANCES (R < RR)
C     IF R .GE. RR         USE MODIFIED T/H TRIPLET EQUATION
C     IF R .LE. RL         USE THE JOHNSON CORRECTION
C     IN BETWEEN           USE THE TRANSITION EQUATION
C--------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION E3(3),E1(3)
      PARAMETER( RL=0.95D0, RR=1.15D0 )
      PARAMETER( Z1=1.D0, Z2=2.D0, Z4=4.D0)
C TRIPLET AND JOHNSON VALUES MAR08/95
C     PARAMETER(
C    .  A1= -0.0460730469,A2=-16.3948753611,A3=-27.6026451962,
C    .  A4=  2.0383359014,A5= -6.8887433326,A6=  1.6216005938,
C    .  C1= -0.4110341110310669,C2= -0.0767398928636804,
C    .  C3=  0.4302169435606523)
C TRIPLET VALUES JUN21
      PARAMETER(
     .  A1= -0.0298546962,A2=-23.9604445036,A3=-42.5185569474,
     .  A4=  2.0382390988,A5=-11.5214861455,A6=  1.5309487826,
     .  C1= -0.4106358351531854,C2= -0.0770355790707090,
     .  C3=  0.4303193846943223) !JUN21 FIT
C  TRIPLET AND JOHNSON VALUES FROM FIT621:
C     PARAMETER(A1=-0.0253496194,A2=-29.2302126444,
C    .          A3=-50.7225015503,A4= 2.0452676876 ,
C    .          A5=-12.2408908509,A6= 1.6733157383 )
C     PARAMETER( C1=-0.4170298146519658,
C    .           C2=-0.0746027774843370,C3= 0.4297899952237434 )
C SURFACE PARAMETERS FROM FIT601.OUT
C     PARAMETER(A1=-0.66129429,A2=-1.99434198,A3=-2.37604328,
C    .          A4= 2.08107802,A5=-0.0313032510,A6=3.76546699,
C    .          C1=-0.4222590135447196,C2=-0.0731117796738824,
C    .          C3= 0.4295918082189010 )
      IPR = 0
      E3(3) = 0.D0
      IF(R.GE.RR )THEN
C       MODIFIED TRUHLAR/HOROWITZ TRIPLET EQUATION:
         EXDR = DEXP( -A4*R )
         RSQ  = R*R
         RA6  = R**(-A6)
         E3(1) = A1* ( A2 + R + A3*RSQ + A5*RA6 )*EXDR
C       FIRST DERIVATIVE OF TRIPLET CURVE:
         RA61 = R**(-A6-Z1)
         E3(2) = A1*EXDR*
     .   ( Z1 -A2*A4 +(Z2*A3-A4)*R -A3*A4*RSQ -A5*A6*RA61 -A4*A5*RA6 )
      END IF
      IF(R.LT.RR )THEN
          DR = R- RL
          CALL VH2OPT95(R,E1,2)
          IF( R.LE.RL ) THEN
C          JOHNSON TRIPLET EQUATION:
            E3(1) = E1(1) + C2*DR + C3
            E3(2) = E1(2) + C2
          ELSE
C          TRANSITION EQUATION:
            E3(1) = E1(1) + C1*DR*DR*DR + C2*DR + C3
            E3(2) = E1(2) + 3.D0*C1*DR*DR + C2
          END IF
      END IF
      IF(IPR.GT.0) WRITE(7,7100) E3
 7100 FORMAT('  TRIPLET:  E3 = ',3(1X,F12.8))
      RETURN
      END
C
C
      SUBROUTINE VH2OPT95(R,E,IDERIV)
C-----------------------------------------------------------------
C JUL09/90 ... SUPER DUPER SPEEDY VERSION
C SELF-CONTAINED VERSION OF SCHWENKE'S H2 POTENTIAL
C ALL DISTANCES IN BOHRS AND ALL ENERGIES IN HARTREES
C (1ST DERIV ADDED ON MAY 2 1989; 2ND DERIV ON MAY 28 1989)
C-----------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION E(3)
      PARAMETER(A0=0.03537359271649620,    A1= 2.013977588700072    ,
     .  A2= -2.827452449964767        ,    A3= 2.713257715593500    ,
     .  A4= -2.792039234205731        ,    A5= 2.166542078766724    ,
     .  A6= -1.272679684173909        ,    A7= 0.5630423099212294   ,
     .  A8= -0.1879397372273814       ,    A9= 0.04719891893374140  ,
     . A10= -0.008851622656489644     ,   A11= 0.001224998776243630 ,
     . A12= -1.227820520228028D-04    ,   A13= 8.638783190083473D-06,
     . A14= -4.036967926499151D-07    ,   A15= 1.123286608335365D-08,
     . A16= -1.406619156782167D-10 )
      PARAMETER( R0=3.5284882D0,  DD=0.160979391D0,
     .           C6=6.499027D0,   C8=124.3991D0,    C10=3285.828D0)
C     EDISS = 0.174445D0
      E(1)  = -999.D0
      E(2)  = -999.D0
      E(3)  = -999.D0
      R2  = R  *R
      R3  = R2 *R
      R4  = R3 *R
      R5  = R4 *R
      R6  = R5 *R
      R7  = R6 *R
      R8  = R7 *R
      R9  = R8 *R
      R10 = R9 *R
      R11 = R10*R
      R12 = R11*R
      R13 = R12*R
      R14 = R13*R
      R15 = R14*R
      R02 = R0*R0
      R04 = R02*R02
      R06 = R04*R02
      RR2  = R2 + R02
      RR4  = R4 + R04
      RR6  = R6 + R06
      RR25 = RR2*RR2*RR2*RR2*RR2
C     GENERAL TERM:  A(I)*R(I-1),  I=0,16
      ALPHAR =  A0/R + A1
     .            + A2 *R   + A3 *R2  + A4 *R3  + A5 *R4  + A6 *R5
     .            + A7 *R6  + A8 *R7  + A9 *R8  + A10*R9  + A11*R10
     .            + A12*R11 + A13*R12 + A14*R13 + A15*R14 + A16*R15
      EXALPH = DEXP(ALPHAR)
      VSR = DD*(EXALPH-1.D0)*(EXALPH-1.D0) - DD
      VLR =  -C6/RR6   -C8/(RR4*RR4)   -C10/RR25
      E(1)=  VSR +  VLR
C
C  CALCULATE FIRST DERIVATIVE IF REQUIRED:
      IF(IDERIV.GE.1)THEN
         R3 = R2*R
         R5 = R4*R
         RR26 = RR25*RR2
         RR43 = RR4*RR4*RR4
C        GENERAL TERM:  (I-1)*A(I)*R**(I-2)  ,  I=0,16
         DALPHR = -A0/R2 + A2 + 2.D0*A3*R
     .          +  3.D0 *A4 *R2  +  4.D0 *A5 *R3  +  5.D0 *A6 *R4
     .          +  6.D0 *A7 *R5  +  7.D0 *A8 *R6  +  8.D0 *A9 *R7
     .          +  9.D0 *A10*R8  + 10.D0 *A11*R9  + 11.D0 *A12*R10
     .          + 12.D0 *A13*R11 + 13.D0 *A14*R12 + 14.D0 *A15*R13
     .          + 15.D0 *A16*R14
         DVSR = 2.D0 *DD *(EXALPH-1.D0) *EXALPH *DALPHR
         DVLR =    6.D0*C6*R5 / (RR6*RR6)
     .          +  8.D0*C8*R3 / RR43  + 10.D0*C10*R / RR26
         E(2) = DVSR + DVLR
      END IF
C
C  CALCULATE SECOND DERIVATIVE IF REQUIRED:
      IF(IDERIV.GE.2)THEN
         R10  = R6*R4
         RR27 = RR26*RR2
         RR44 = RR43*RR4
         RR62 = RR6*RR6
         RR63 = RR62*RR6
C        GENERAL TERM: (I-1)*(I-2)*A(I)*R**(I-3),    I=0,16
         DDALPH = 2.D0*A0/R3 +  2.D0*A3      +  6.D0*A4 *R
     .     + 12.D0*A5 *R2    + 20.D0*A6 *R3  + 30.D0*A7 *R4
     .     + 42.D0*A8 *R5    + 56.D0*A9 *R6  + 72.D0*A10*R7
     .     + 90.D0*A11*R8    +110.D0*A12*R9  +132.D0*A13*R10
     .     +156.D0*A14*R11   +182.D0*A15*R12 +210.D0*A16*R13
         DDVSR = 2.D0 *DD *EXALPH
     .   *( (2.D0*EXALPH-1.D0)*DALPHR*DALPHR + (EXALPH-1.D0)*DDALPH )
         DDVLR =- 72.D0* C6 *R10 / RR63 -96.D0 *C8 *R6 / RR44
     .          -120.D0*C10 *R2  / RR27 +30.D0 *C6 *R4 / RR62
     .          + 24.D0* C8 *R2  / RR43 +10.D0 *C10    / RR26
         E(3) = DDVSR + DDVLR
      END IF
      RETURN
      END
C
      SUBROUTINE H3LOND95(R,VLON,DVLON)
C----------------------------------------------------------------------
C VERSION OF MAY 12/90  ... DERIVATIVES CORRECTED (0.5 CHANGED TO 0.25)
C CALCULATES THE H3 LONDON TERMS AND DERIVATIVES
C MODIFIED OCT 7/89 TO INCLUDE EPS**2 TERM WHICH ROUNDS OFF THE
C CUSP IN THE H3 POTENTIAL WHICH OCCURS AT EQUILATERAL TRIANGLE
C CONFIGURATIONS
C----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      REAL*8 Q(3),J(3),JT
      DIMENSION R(3),E1(3),E3(3),ESING(3),ETRIP(3),DVLON(3)
      DIMENSION DE1(3),DE3(3)
C     DIMENSION DJ1(3),DJ2(3),DJ3(3)
      PARAMETER( HALF=0.5D0, TWO=2.D0 , EPS2=1.D-12 )
      IPR = 0
      DO I=1,3
         CALL VH2OPT95(R(I),ESING,2)
          E1(I) = ESING(1)
         DE1(I) = ESING(2)
         CALL TRIPLET95(R(I),ETRIP,2)
         IF(IPR.GT.0) WRITE(7,7400) I,ESING,ETRIP
          E3(I) = ETRIP(1)
         DE3(I) = ETRIP(2)
         Q(I)  = HALF*(E1(I) + E3(I))
         J(I)  = HALF*(E1(I) - E3(I))
      END DO
      SUMQ  =   Q(1) + Q(2) + Q(3)
      SUMJ  =   DABS( J(2)-J(1) )**2
     .        + DABS( J(3)-J(2) )**2
     .        + DABS( J(3)-J(1) )**2
      JT     = HALF*SUMJ + EPS2
      ROOTJT = DSQRT(JT)
      VLON   = SUMQ - ROOTJT
      IF(IPR.GT.0) THEN
         WRITE(7,7410) SUMQ,SUMJ
         WRITE(7,7420) VLON,ROOTJT
      END IF
C  CALCULATE THE DERIVATIVES WITH RESPECT TO R(I):
      DVLON(1) = HALF*(DE1(1)+DE3(1))
     .         - 0.25D0*(TWO*J(1)-J(2)-J(3))*(DE1(1)-DE3(1))/ROOTJT
      DVLON(2) = HALF*(DE1(2)+DE3(2))
     .         - 0.25D0*(TWO*J(2)-J(3)-J(1))*(DE1(2)-DE3(2))/ROOTJT
      DVLON(3) = HALF*(DE1(3)+DE3(3))
     .         - 0.25D0*(TWO*J(3)-J(1)-J(2))*(DE1(3)-DE3(3))/ROOTJT
      IF(IPR.GT.0) THEN
         WRITE(7,7000) R,E1,E3,VLON
         WRITE(7,7100) Q,J
         WRITE(7,7200) DVLON
      END IF
 7000 FORMAT('             R = ',3(1X,F12.6),/,
     .       '            E1 = ',3(1X,F12.8),/,
     .       '            E3 = ',3(1X,F12.8),/,
     .       '          VLON = ',1X,F12.8)
 7100 FORMAT(13X,'Q = ',3(1X,E12.6),/,13X,'J = ',3(1X,E12.6))
 7200 FORMAT('         DVLON = ',3(1X,G12.6))
 7400 FORMAT('FROM SUBR.LONDON: ',/,
     .       '  USING R',I1,':   ESINGLET=',3(1X,F12.8),/,
     .       '         ',1X,'    ETRIPLET=',3(1X,F12.8))
 7410 FORMAT('         SUMQ = ',G12.6,'        SUMJ = ',G12.6)
 7420 FORMAT('         VLON = ',F12.8,'      ROOTJT = ',G12.6)
      RETURN
      END
C
      SUBROUTINE VASCAL95(RPASS,VAS,DVAS)
C------------------------------------------------------------------
C VERSION OF APR12/95  950308 VALUES
C VERSION OF OCT11/90  FIT632C.OUT VALUES
C VERSION OF OCT5/90   SURF626 VALUES
C  CALCULATE THE ASYMMETRIC CORRECTION TERM AND ITS DERIVATIVES
C  SEE EQUATIONS [14] TO [16] OF TRUHLAR/HOROWITZ 1978 PAPER
C------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION DVAS(3),DA(3),DS(3),RPASS(3)
C VASYM VALUES JUN21
      PARAMETER(
     . AA1=0.3788951192E-02, AA2=0.1478100901E-02,
     . AA3=-.1848513849E-03, AA4=0.9230803609E-05,
     . AA5=-.1293180255E-06, AA6=0.5237179303E+00,
     . AA7=-.1112326215E-02) !JUN21 FIT
C--- VASYM VALUES MAR08.95
C     PARAMETER(
C    . AA1=0.3759731624E-02, AA2=0.1476254095E-02,
C    . AA3=-.1866759453E-03, AA4=0.9218646237E-05,
C    . AA5=-.1287906069E-06, AA6=0.5201790843E+00,
C    . AA7=-.1062909514E-02)
C--- VASYM VALUES FROM FIT632C ----------------------
C     PARAMETER(
C    . AA1=0.3438222224E-02,AA2=0.1398145763E-02,
C    . AA3=-.1923999449E-03,AA4=0.9712737075E-05,
C    . AA5=-.1263794562E-06,AA6=0.5181432712E+00,
C    . AA7=-.9487002995E-03 )
      IPR = 0
      R1 = RPASS(1)
      R2 = RPASS(2)
      R3 = RPASS(3)
      R  = R1 + R2 + R3
      RSQ = R*R
      RCU = RSQ*R
C   CALCULATE THE VAS TERM FIRST (EQ.14 OF TRUHLAR/HOROWITZ)
      CALL ACALC95(R1,R2,R3,A,DA)
        A2 = A *A
        A3 = A2*A
        A4 = A3*A
        A5 = A4*A
        EXP1 = DEXP(-AA1*RCU)
        EXP6 = DEXP(-AA6*R)
        S = AA2*A2 + AA3*A3 + AA4*A4 + AA5*A5
      VAS = S*EXP1 +  AA7*A2 *EXP6 / R
         DS(1)  = ( 2.D0*AA2*A  +3.D0*AA3*A2
     .             +4.D0*AA4*A3 +5.D0*AA5*A4) * DA(1)
         DVAS(1) =  -3.D0*AA1*RSQ*S*EXP1 + DS(1)*EXP1
     .             -AA7*A2*EXP6/RSQ  + 2.D0*AA7*A*DA(1)*EXP6/R
     .             -AA6*AA7*A2*EXP6/R
         DS(2)  = ( 2.D0*AA2*A  +3.D0*AA3*A2
     .             +4.D0*AA4*A3 +5.D0*AA5*A4) * DA(2)
         DVAS(2) =  -3.D0*AA1*RSQ*S*EXP1 + DS(2)*EXP1
     .             -AA7*A2*EXP6/RSQ  + 2.D0*AA7*A*DA(2)*EXP6/R
     .             -AA6*AA7*A2*EXP6/R
         DS(3)  = ( 2.D0*AA2*A  +3.D0*AA3*A2
     .             +4.D0*AA4*A3 +5.D0*AA5*A4) * DA(3)
         DVAS(3) =  -3.D0*AA1*RSQ*S*EXP1 + DS(3)*EXP1
     .             -AA7*A2*EXP6/RSQ  + 2.D0*AA7*A*DA(3)*EXP6/R
     .             -AA6*AA7*A2*EXP6/R
      IF(IPR.GT.0) WRITE(7,7100) VAS,DS,DVAS
 7100 FORMAT('    FROM SUBR.VASCAL:   VAS  = ',  1X,G12.6, /,
     .       '                        DS   = ',3(1X,G12.6),/,
     .       '                        DVAS = ',3(1X,G12.6))
      RETURN
      END
C
      SUBROUTINE ACALC95(R1,R2,R3,A,DA)
C---------------------------------------------------------------------
C  VERSION OF MAY 1, 1990
C  BASED ON EQUATIONS FROM NOTES DATE APRIL 4, 1990
C  CALCULATE THE A VALUE AND ITS DERIVATIVES
C           A  = DABS[ (R1-R2)*(R2-R3)*(R3-R1) ]
C---------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION DA(3)
      IPR = 0
      A = (R1-R2)*(R2-R3)*(R3-R1)
      DA(1) = ( -2.D0*R1 + R2 + R3 )*(R2-R3)
      DA(2) = ( -2.D0*R2 + R3 + R1 )*(R3-R1)
      DA(3) = ( -2.D0*R3 + R1 + R2 )*(R1-R2)
      IF(A.LT.0.D0)THEN
         A = -A
         DA(1) = -DA(1)
         DA(2) = -DA(2)
         DA(3) = -DA(3)
      END IF
      IF(IPR.GT.0) WRITE(7,7100) A,DA
 7100 FORMAT('ACALC ENTER ---------------------------------------',/,
     .       '     A = ',F15.10,'   DA = ',3(1X,G12.6),/,
     .       'ACALC EXIT ----------------------------------------')
      RETURN
      END
C
      SUBROUTINE COMPAC95(R,ICOMPC,T,DT)
C---------------------------------------------------------------
C  VERSION OF MAY 14/90 ... CALCULATES T AND DT VALUES ALSO
C  DECIDE WHETHER OR NOT THIS PARTICULAR GEOMETRY IS COMPACT,
C  THAT IS, ARE ANY OF THE THREE DISTANCES SMALLER THAN THE
C  RR VALUE FROM THE JOHNSON CORRECTION.
C-----------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION R(3),T(3),DT(3)
      PARAMETER( RR = 1.15D0, RP = 1.25D0 )
C  FIRST SEE IF THIS IS A COMPACT GEOMETRY:
      DO I=1,3
         T(I) = 0.D0
         DT(I)= 0.D0
      END DO
      ICOMPC = 0
      IF(R(1).LT.RR) ICOMPC = ICOMPC + 1
      IF(R(2).LT.RR) ICOMPC = ICOMPC + 1
      IF(R(3).LT.RR) ICOMPC = ICOMPC + 1
      IF(ICOMPC.EQ.0) RETURN
C CALCULATE THE T(I) VALUES:
      DO I=1,3
      IF(R(I).LT.RR) THEN
         TOP = RR-R(I)
         BOT = RP-R(I)
         TOP2 = TOP  * TOP
         TOP3 = TOP2 * TOP
         BOT2 = BOT  * BOT
         T(I)  = TOP3/BOT
         DT(I) = -3.D0*TOP2/BOT + TOP3/BOT2
      END IF
      END DO
      RETURN
      END
C
      SUBROUTINE CASYM95( R,CAS,DCAS,ID,T,DT )
C---------------------------------------------------------------
C APR12/95 ... SURFACE950308 PARAMETERS ADDED
C VERSION OF SEPT14/90
C  THE COMPACT ASYMMETRIC CORRECTION TERM AND DERIVATIVES
C---------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION R(3),T(3)
      DIMENSION DPR(3),DT(3),DSUMT(3),DTERM1(3),DETERM(3),DSERIES(3),
     .          DCAS(3),DA(3)
C CASYM VALUES JUN21
      PARAMETER(
     . U1=0.2210243144E+00, U2=0.4367417579E+00, U3=0.6994985432E-02,
     . U4=0.1491096501E+01, U5=0.1602896673E+01, U6=-.2821747323E+01,
     . U7=0.4948310833E+00, U8=-.3540394679E-01, U9=-.3305809954E+01,
     .U10=0.3644382172E+01,U11=-.9997570970E+00,U12=0.7989919534E-01,
     .U13=-.1075807322E-02) !JUN21 FIT
C---- CASYM VALUES MAR08.95
C     PARAMETER(
C    . U1=0.5120831287E+00, U2=0.1002277242E+01, U3=0.6850007419E-02,
C    . U4=-.2038751706E+01, U5=0.7027811909E+01, U6=-.4881767278E+01,
C    . U7=0.8801769106E+00, U8=-.6296419648E-01, U9=-.8125516783E+01,
C    .U10=0.6073964424E+01,U11=-.1451402523E+01,U12=0.1165084183E+00,
C    .U13=-.1176579871E-02)
C---- CASYM VALUES FROM FIT633A
C     PARAMETER(
C    . U1=0.1537481166E+00, U2=0.2745950036E+00, U3=0.7501206780E-02,
C    . U4=0.3119136023E+01, U5=0.9969170798E+00, U6=-.3373682823E+01,
C    . U7=0.6807215913E+00, U8=-.4920325491E-01, U9=-.3919467989E+01,
C    .U10=0.5085532326E+01,U11=-.1415264778E+01,U12=0.1138681785E+00,
C    .U13=-.1525367566E-02)
      IPR = 0
      CAS = 0.D0
      DCAS(1) = 0.D0
      DCAS(2) = 0.D0
      DCAS(3) = 0.D0
      CALL ACALC95(R(1),R(2),R(3),A,DA)
      A2 = A*A
C     IF(A.EQ.0.D0) RETURN
      SUMT = T(1) + T(2) + T(3)
      SR   = R(1) + R(2) + R(3)
      PR   = R(1) * R(2) * R(3)
      SR2  = SR*SR
      SR3  = SR2*SR
      PR2  = PR*PR
      PR3  = PR2*PR
C    WRITE OUT THE SERIES EXPLICITLY:
      SERIES = 1.D0 + U4/PR2 +  U5/PR + U6 +   U7*PR +  U8*PR2
     .           + A*(U9/PR2 + U10/PR + U11 + U12*PR + U13*PR2)
      TERM1  = U1/PR**U2
      ETERM  = DEXP(-U3*SR3)
      CAS    = SUMT * A2 * TERM1 * SERIES * ETERM
      IF(IPR.GT.0) THEN
            WRITE(7,*)
            WRITE(7,*) 'CASYM: ------------------'
            WRITE(7,*) ' T(I) = ',T
            WRITE(7,*) 'DT(I) = ',DT
            WRITE(7,*) ' ID = ',ID
            WRITE(7,7400) SERIES,TERM1,ETERM,CAS
            WRITE(7,*) ' CAS = ',CAS
      END IF
      IF(ID.GT.0)THEN
            DPR(1) = R(2)*R(3)
            DPR(2) = R(3)*R(1)
            DPR(3) = R(1)*R(2)
         DO I=1,3
            DSUMT(I) = DT(I)
            DTERM1(I)=  -1.D0*U1*U2*PR**(-U2-1.D0)*DPR(I)
            DETERM(I)= ETERM *(-3.D0*U3*SR2)
            DSERIES(I)=
     .        DPR(I)*( -2.D0*U4/PR3  -U5/PR2 +U7  +2.D0*U8*PR    )
     .        +DA(I)*( U9/PR2 +U10/PR +U11 +U12*PR +U13*PR2    )
     .        +A*DPR(I)*( -2.D0*U9/PR3 -U10/PR2 +U12 + 2.D0*U13*PR )
            DCAS(I) =
     .        DSUMT(I)      * A2    * TERM1 * SERIES * ETERM
     .      + 2.D0*A*DA(I)  * SUMT  * TERM1 * SERIES * ETERM
     .      + DTERM1(I)     * SUMT  * A2    * SERIES * ETERM
     .      + DSERIES(I)    * SUMT  * A2    * TERM1  * ETERM
     .      + DETERM(I)     * SUMT  * A2    * TERM1  * SERIES
         END DO
         IF(IPR.GT.0) THEN
            WRITE(7,7500) DPR,DT,DTERM1,DETERM,DSERIES,DCAS
            WRITE(7,*) ' DCAS = ',DCAS
         END IF
      END IF
      RETURN
 7400 FORMAT('SUBR.CAS:   SERIES = ',G12.6,'     TERM1 = ',G12.6,/,
     .       '             ETERM = ',G12.6,'      CAS  = ',G12.6)
 7500 FORMAT('    DERIVATIVES: DPR = ',3(1X,G12.6),/,
     .       '                 DT  = ',3(1X,G12.6),/,
     .       '              DTERM1 = ',3(1X,G12.6),/,
     .       '              DETERM = ',3(1X,G12.6),/,
     .       '             DSERIES = ',3(1X,G12.6),/,
     .       '              DCAS   = ',3(1X,G12.6))
      END
C
      SUBROUTINE CSYM95(R,CAL,DCAL)
C---------------------------------------------------------------
C VERSION OF APR12/95  950308 VALUES
C VERSION OF OCT12/90  SURF636 VALUES
C  CALCULATE THE 'COMPACT ALL' CORRECTION TERM AND DERIVATIVES
C  A CORRECTION TERM (ADDED SEPT 11/89), WHICH ADDS A SMALL
C  CORRECTION TO ALL COMPACT GEOMETRIES
C---------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION R(3),DCAL(3),G(3)
C     DIMENSION T(3)
      DIMENSION DG(3),SUMV(3)
      PARAMETER( RR=1.15D0, RP=1.25D0 )
C CSYM VALUES JUN21
      PARAMETER(
     . V1=-.2071708868E+00, V2=-.5672350377E+00, V3=0.9058780367E-02) !JUN21 FIT
C---- CSYM VALUES MAR08/95
C     PARAMETER(
C    . V1=-.2210049400E+00, V2=-.7054469608E+00, V3=0.4088898394E-02)
C---- CSYM VALUES FROM FIT633A
C     PARAMETER(
C    . V1=-.2070776049E+00, V2=-.5350898737E+00, V3=0.1011861942E-01)
      CAL   = 0.D0
      IPR   = 0
      SR    = R(1)+R(2)+R(3)
      SR2   = SR*SR
      SR3   = SR*SR2
      EXP3  = DEXP( -V3*SR3 )
      DEXP3 = -3.D0*V3*SR2*EXP3
      DO I=1,3
         RI      = R(I)
         RRRI    = RR-RI
         RRRI2   = RRRI*RRRI
         RRRI3   = RRRI*RRRI2
         RPRI    = RP-RI
         RPRI2   = RPRI*RPRI
         G(I)    = 0.D0
         DG(I)   = 0.D0
         SUMV(I) = V1+V1*V2*RI
         IF(RI.LT.RR) THEN
            G(I)  = (RRRI3/RPRI) *SUMV(I)
            DG(I) = (RRRI3/RPRI2)*SUMV(I)
     .                -3.D0*(RRRI2/RPRI)*SUMV(I)
     .                + (RRRI3/RPRI)*V1*V2
         END IF
      END DO
      SUMG = G(1) + G(2) + G(3)
      CAL  = SUMG*EXP3
      DCAL(1) = DG(1)*EXP3 + SUMG*DEXP3
      DCAL(2) = DG(2)*EXP3 + SUMG*DEXP3
      DCAL(3) = DG(3)*EXP3 + SUMG*DEXP3
      IF(IPR.GT.0)THEN
         WRITE(7,*)
         WRITE(7,7100) CAL
         WRITE(7,7000) G,DG,SUMV,DCAL
         WRITE(7,*) 'EXITING SUBR.CSYM'
      END IF
 7100 FORMAT('CSYM ENTER ----------------------------------------',/,
     .       '    CAL = ',1X,G20.14)
 7000 FORMAT('      G = ',3(1X,G12.6),/,
     .       '     DG = ',3(1X,G12.6),/,
     .       '   SUMV = ',3(1X,G12.6),/,
     .       '   DCAL = ',3(1X,G16.10),/,
     .       'CSYM EXIT -----------------------------------------')
      RETURN
      END
C
      SUBROUTINE VBCB95(RPASS,ICOMPC,T,DT,IPR,
     .                  VBNDA,VBNDB,DVBNDA,DVBNDB,
     .                  CBNDA,CBNDB,DCBNDA,DCBNDB)
C---------------------------------------------------------------
C APR12/95 SURFACE950308 VALUES ADDED
C JUL24/91 FIT705 CBEND VALUES ADDED
C FEB27/91 MODIFIED TO MATCH EQUATION IN H3 PAPER MORE CLOSELY
C NOV 4/90 VBEND COEFFICIENTS NOW A,G  CBEND COEFF'S STILL C,D
C IN THIS VERSION, THE DERIVATIVES ARE ALWAYS CALCULATED
C SUBROUTINES VBEND, CBEND AND B1AB ALL COMBINED INTO THIS ONE
C MODULE IN ORDER TO IMPROVE EFFICIENCY BY NOT HAVING TO PASS
C AROUND B1A,B1B,B2,B3A,B3B FUNCTIONS AND DERIVATIVES
C  B1A = 1 - SUM OF [ P1(COS(THETA(I))) ]
C  B1B = 1 - SUM OF [ P3(COS(THETA(I))) ]
C--------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ARRAYS REQUIRED FOR B1,B2,B3 CALCULATIONS:
      DIMENSION RPASS(3),DB1A(3),DB1B(3),DB2(3),DB3(6)
C     DIMENSION TH(3)
C     ARRAYS REQUIRED FOR VBEND CALCULATIONS:
      DIMENSION DVBNDA(3),DVBNDB(3)
      DIMENSION DVB1(3),DVB2(3),DVB3(3),DVB4(3),DVB5(3)
C     DIMENSION DVBND(3)
      DIMENSION VBND(2)
      DIMENSION VB(2,25)
C     ARRAYS REQUIRED FOR CBEND CALCULATIONS:
      DIMENSION CBNDS(2),DCBNDS(2,3)
      DIMENSION DCB1(3),DCB2(3),DCB3(3),DCB4(3),DCB5(3),DCB6(3),
     .          DCB7(3),DCB8(3)
      DIMENSION T(3),DP(3)
      DIMENSION DT(3),DCBNDA(3),DCBNDB(3)
      DIMENSION CB(2,25)
      PARAMETER( Z58=0.625D0, Z38=0.375D0 )
C     PARAMETERS REQUIRED FOR VBEND CALCULATIONS:
      PARAMETER(BETA1=0.52D0, BETA2=0.052D0, BETA3=0.79D0 )
C VBENDA TERMS JUN21         EXPTERMS= 0.52D0, 0.052D0, 0.79D0
      PARAMETER(
     .A11=-.1838073394E+03,A12=0.1334593242E+02,A13=-.2358129537E+00,
     .A21=-.4668193478E+01,A22=0.7197506670E+01,A23=0.2162004275E+02,
     .A24=0.2106294028E+02,A31=0.4242962586E+01,A32=0.4453505045E+01,
     .A41=-.1456918088E+00,A42=-.1692657366E-01,A43=0.1279520698E+01,
     .A44=-.4898940075E+00,A51=0.1742295219E+03,A52=0.3142175348E+02,
     .A53=0.5152903406E+01) !JUN21 FIT
C VBENDB TERMS JUN21
      PARAMETER(
     .G11=-.4765732725E+02,G12=0.3648933563E+01,G13=-.7141145244E-01,
     .G21=0.1002349176E-01,G22=0.9989856329E-02,G23=-.4161953634E-02,
     .G24=0.9075807910E-03,G31=-.2693628729E+00,G32=-.1399065763E-01,
     .G41=-.1417634346E-01,G42=-.4870024792E-03,G43=0.1312231847E+00,
     .G44=-.4409850519E-01,G51=0.5382970863E+02,G52=0.4587102824E+01,
     .G53=0.1768550515E+01) !JUN21 FIT
C    VBENDA MAR08/95   EXPTERMS= 0.52D0, 0.052D0, 0.79D0
C     PARAMETER(
C    .A11=-.1779469255E+03,A12=0.1292511538E+02,A13=-.2284450520E+00,
C    .A21=-.4671094689E+01,A22=0.7810423901E+01,A23=0.2359968959E+02,
C    .A24=0.2293876132E+02,A31=0.4191795902E+01,A32=0.4456025797E+01,
C    .A41=-.1419862958E+00,A42=-.1667760578E-01,A43=0.1246997125E+01,
C    .A44=-.4777517290E+00,A51=0.1681125268E+03,A52=0.3067567046E+02,
C    .A53=0.4942041527E+01)
C    VBENDB MAR08/95
C     PARAMETER(
C    .G11=-.4677295200E+02,G12=0.3587873970E+01,G13=-.7051720560E-01,
C    .G21=0.9549632701E-02,G22=0.9971623818E-02,G23=-.4040392363E-02,
C    .G24=0.9045746595E-03,G31=-.2746842691E+00,G32=-.1412945503E-01,
C    .G41=-.1337907240E-01,G42=-.6200741002E-03,G43=0.1257251291E+00,
C    .G44=-.4195584422E-01,G51=0.5287171694E+02,G52=0.4490366264E+01,
C    .G53=0.1735452866E+01)
C
C CBENDA TERMS JUN21/95
      PARAMETER(
     .C11=0.1860299931E+04,C12=-.6134458037E+03,C13=0.7337207161E+02,
     .C14=-.2676717625E+04,C15=0.1344099415E+04,C21=0.1538913137E+03,
     .C22=0.4348007369E+02,C23=0.1719720677E+03,C24=0.2115963042E+03,
     .C31=-.7026089414E+02,C32=-.1300938992E+03,C41=0.1310273564E+01,
     .C42=-.6175149574E+00,C43=-.2679089358E+02,C44=0.5577477171E+01,
     .C51=-.3543353539E+04,C52=-.3740709591E+03,C53=0.7979303144E+02,
     .C61=-.1104230585E+04,C62=0.4603572025E+04,C63=-.5593496634E+04,
     .C71=-.1069406434E+02,C72=0.1021807153E+01,C73=0.6669828341E-01,
     .C74=0.4168542348E+02,C75=0.1751608567E+02,C81=0.9486883238E+02,
     .C82=-.1519334221E+02,C83=0.4024697252E+04,C84=-.2225159395E+02) !JUN21
C           (LAST 4 PARAMETERS RENUMBERED)
C CBENDB TERMS JUN21/95
      PARAMETER(
     .D11=0.4203543357E+03,D12=-.4922474096E+02,D13=0.3362942544E+00,
     .D14=-.3827423082E+03,D15=0.1746726001E+03,D21=0.1699995737E-01,
     .D22=0.1513036778E-01,D23=0.2659119354E-01,D24=-.5760387483E-02,
     .D31=0.1020622621E+02,D32=0.1050536271E-01,D41=0.6836172780E+00,
     .D42=-.1627858240E+00,D43=-.6925485045E+01,D44=0.1632567385E+01,
     .D51=0.1083595009E+04,D52=0.4641431791E+01,D53=-.8233144461E+00,
     .D61=-.6157225942E+02,D62=0.3094361471E+03,D63=-.3299631143E+03,
     .D71=0.8866227120E+01,D72=-.1382126854E+01,D73=0.7620770145E-01,
     .D74=-.5145757859E+02,D75=0.2046097265E+01,D81=0.2540775558E+01,
     .D82=-.4889246569E+00,D83=-.1127439280E+04,D84=-.2269932295E+01) !JUN21
C           (LAST 4 PARAMETERS RENUMBERED)
C
C    CBENDA MAR08/95
C     PARAMETER(
C    .C11=0.1983833377E+04,C12=-.7161674985E+03,C13=0.9480354622E+02,
C    .C14=-.2860199829E+04,C15=0.1424701828E+04,C21=0.1544592401E+03,
C    .C22=0.3684848293E+02,C23=0.1717816399E+03,C24=0.2060270139E+03,
C    .C31=-.1215015279E+03,C32=-.1370574974E+03,C41=0.8903858200E+00,
C    .C42=-.6496543267E+00,C43=-.2367464822E+02,C44=0.5098769966E+01,
C    .C51=0.6728307258E+03,C52=-.3825078986E+03,C53=0.8128185587E+02,
C    .C61=-.1141379097E+04,C62=0.4771127549E+04,C63=-.5713570141E+04,
C    .C71=-.7394045711E+01,C72=0.9888694698E+00,C73=0.7493009017E-01,
C    .C74=0.9590644736E+02,C75=0.1925781563E+02,C81=0.1001295468E+03,
C    .C82=-.1533150643E+02,C83=-.1850297943E+03,C84=-.2420454635E+02)
C     (LAST 4 PARAMETERS RENUMBERED)
C    CBENDB TERMS MAR08/95
C     PARAMETER(
C    .D11=0.4441478933E+03,D12=-.5345816836E+02,D13=0.1443665553E+01,
C    .D14=-.4155134339E+03,D15=0.1912235377E+03,D21=-.3697316400E-02,
C    .D22=0.1688497284E-01,D23=0.2330055461E-01,D24=-.4670024282E-02,
C    .D31=0.6492099426E+01,D32=0.1597054504E-01,D41=0.6701003237E+00,
C    .D42=-.1868909419E+00,D43=-.6709596498E+01,D44=0.1713120242E+01,
C    .D51=-.5022064388E+04,D52=0.2322997491E+01,D53=-.2710031511E+00,
C    .D61=-.7265968242E+02,D62=0.3593588680E+03,D63=-.3933599161E+03,
C    .D71=0.9312252325E+01,D72=-.1380396384E+01,D73=0.7373026488E-01,
C    .D74=-.5070954743E+02,D75=0.7931122062E+00,D81=0.3599502276E+01,
C    .D82=-.5609868931E+00,D83=0.4980220561E+04,D84=-.1087179983E+01)
C     (LAST 4 PARAMETERS RENUMBERED)
C
C VBENDA VALUES FROM FIT634B (USED FOR SURF706)
C     PARAMETER(
C    .A11=-.2918252280E+03,A12=0.2164569141E+02,A13=-.4005497543E+00,
C    .A21=-.2890774947E+01,A22=0.1032032542E+02,A23=0.2681748056E+02,
C    .A24=0.2633751055E+02,A31=0.6180641351E+01,A32=0.5037667041E+01,
C    .A41=-.1125570079E+00,A42=-.3176529304E-02,A43=0.9068915355E+00,
C    .A44=-.7228418516E+00,A51=0.2785898232E+03,A52=0.4764442446E+02,
C    .A53=0.8621545662E+01)
C   VBENDB VALUES FROM FIT634B (USED FOR SURF706)
C     PARAMETER(
C    .G11=-.4241912309E+02,G12=0.2951365281E+01,G13=-.4840201514E-01,
C    .G21=-.1159168549E-03,G22=0.8688003567E-02,G23=-.3486923900E-02,
C    .G24=0.8312212839E-03,G31=0.5621810473E-01,G32=-.9776930747E-02,
C    .G41=-.1178456251E-01,G42=0.3491086729E-02,G43=0.7430516993E-01,
C    .G44=-.9643636957E-01,G51=0.4735533782E+02,G52=0.3001038808E+01,
C    .G53=0.1896630453E+01)
C
C PARAMETERS REQUIRED FOR CBEND CALCULATIONS:
C
C-- CBENDA VALUES FROM FIT706D.OUT
C     PARAMETER(
C    .C11=0.7107064647E+04,C12=-.3728421267E+04,C13=0.1757654624E+03,
C    .C14=-.9725998132E+04,C15=0.4665086074E+04,C21=-.4435165986E+02,
C    .C22=0.1604477309E+03,C23=0.5805142925E+03,C24=0.6892349445E+03,
C    .C31=0.6581730442E+03,C32=0.6078389739E+02,C41=0.2885182566E+01,
C    .C42=-.1728169916E+01,C43=-.1119535503E+03,C44=0.4052536250E+02,
C    .C51=0.2540505673E+03,C52=-.5762083627E+03,C53=0.1295901320E+03,
C    .C61=-.2131706075E+04,C62=0.9084452020E+04,C63=-.1138253963E+05,
C    .C71=-.3964298833E+02,C72=-.5019979693E+01,C73=0.2906541488E+00,
C    .C74=0.1212943686E+04,C75=0.4140463415E+02,C81=0.1752855549E+03,
C    .C82=-.2496320107E+02,C83=0.3765413052E+03,C84=-.5480488130E+02)
C-- CBENDB VALUES FROM FIT706D.OUT
C     PARAMETER(
C    .D11=0.1917166552E+04,D12=-.6542563392E+03,D13=0.6793758367E+02,
C    .D14=-.1694968847E+04,D15=0.6866649703E+03,D21=-.2137567948E+00,
C    .D22=0.4975938228E-01,D23=0.9364998295E-01,D24=-.2444320779E-01,
C    .D31=-.2863126914E+02,D32=0.5443219625E-01,D41=0.9673956120E+00,
C    .D42=-.1160159706E+01,D43=-.2424199759E+02,D44=0.8569424490E+01,
C    .D51=-.6517635862E+04,D52=0.1518098147E+03,D53=-.2706514366E+02,
C    .D61=0.4308392956E+02,D62=-.1234851732E+03,D63=0.2320626055E+03,
C    .D71=0.1049541418E+02,D72=-.2424169341E+01,D73=0.1745646946E+00,
C    .D74=0.2603615561E+02,D75=0.1345799970E+02,D81=-.6653710513E+01,
C    .D82=-.2576854447E+00,D83=0.6172608425E+04,D84=-.1328142473E+02)
C END OF PARAMETERS
C
C   FEB27/91 NEW C51 = C51+C83;   NEW D51 = D51+D83
      CX1 = C51 + C83
      DX1 = D51 + D83
      R1 = RPASS(1)
      R2 = RPASS(2)
      R3 = RPASS(3)
      T1 = R1*R1 -R2*R2 -R3*R3
      T2 = R2*R2 -R3*R3 -R1*R1
      T3 = R3*R3 -R1*R1 -R2*R2
C  CALCULATE THE COSINES OF THE THREE INTERNAL ANGLES:
      C1 = T1 / (-2.D0*R2*R3)
      C2 = T2 / (-2.D0*R3*R1)
      C3 = T3 / (-2.D0*R1*R2)
      SUM = C1 + C2 + C3
      B1A = 1.D0 - SUM
      C1CUBE = C1*C1*C1
      C2CUBE = C2*C2*C2
      C3CUBE = C3*C3*C3
      COS3T1 = 4.D0*C1CUBE - 3.D0*C1
      COS3T2 = 4.D0*C2CUBE - 3.D0*C2
      COS3T3 = 4.D0*C3CUBE - 3.D0*C3
      SUMB   = COS3T1 + COS3T2 + COS3T3
      B1B    = 1.D0 - ( Z58*SUMB + Z38*SUM )
C  CALCULATE DERIVATIVES IF DESIRED
         DC1DR1 = -R1/(R2*R3)
         DC2DR2 = -R2/(R1*R3)
         DC3DR3 = -R3/(R1*R2)
         DC1DR2 = ( T1/(R2*R2) + 2.D0 )/(2.D0*R3)
         DC1DR3 = ( T1/(R3*R3) + 2.D0 )/(2.D0*R2)
         DC2DR1 = ( T2/(R1*R1) + 2.D0 )/(2.D0*R3)
         DC2DR3 = ( T2/(R3*R3) + 2.D0 )/(2.D0*R1)
         DC3DR1 = ( T3/(R1*R1) + 2.D0 )/(2.D0*R2)
         DC3DR2 = ( T3/(R2*R2) + 2.D0 )/(2.D0*R1)
         DB1A(1) = -1.D0*( DC1DR1 + DC2DR1 + DC3DR1 )
         DB1A(2) = -1.D0*( DC1DR2 + DC2DR2 + DC3DR2 )
         DB1A(3) = -1.D0*( DC1DR3 + DC2DR3 + DC3DR3 )
         D1 = 12.D0*C1*C1 - 3.D0
         D2 = 12.D0*C2*C2 - 3.D0
         D3 = 12.D0*C3*C3 - 3.D0
         DB1B(1) = -Z58*( D1*DC1DR1 + D2*DC2DR1 + D3*DC3DR1 )
     .             -Z38*(    DC1DR1 +    DC2DR1 +    DC3DR1 )
         DB1B(2) = -Z58*( D1*DC1DR2 + D2*DC2DR2 + D3*DC3DR2 )
     .             -Z38*(    DC1DR2 +    DC2DR2 +    DC3DR2 )
         DB1B(3) = -Z58*( D1*DC1DR3 + D2*DC2DR3 + D3*DC3DR3 )
     .             -Z38*(    DC1DR3 +    DC2DR3 +    DC3DR3 )
CD    IF(IPR.GT.1)THEN
CD        WRITE(7,*)
CD        WRITE(7,*) ' FROM SUBR.VBCB -----------------------------'
CD        WRITE(7,6000) RPASS
CD        WRITE(7,6010) B1A,B1B
CD        WRITE(7,6020) DB1A,DB1B
CD        IF(IPR.GT.2)THEN
CD           WRITE(7,7000) DC1DR1,DC1DR2,DC1DR3,
CD   .                     DC2DR1,DC2DR2,DC2DR3,
CD   .                     DC3DR1,DC3DR2,DC3DR3
CD           WRITE(7,7010) T1,T2,T3,C1,C2,C3,D1,D2,D3
CD        END IF
CD    END IF
C
C  CALCULATE THE QUANTITIES USED BY BOTH VBEND AND CBEND:
C
      R    = R1 + R2 + R3
      RSQ  = R*R
      B2   = 1.D0/R1 + 1.D0/R2 + 1.D0/R3
      B3   = (R2-R1)*(R2-R1) + (R3-R2)*(R3-R2) + (R1-R3)*(R1-R3)
      EPS2 = 1.D-12
      B3B  = DSQRT( B3 + EPS2 )
         DB2(1) = -1.D0/(R1*R1)
         DB2(2) = -1.D0/(R2*R2)
         DB2(3) = -1.D0/(R3*R3)
         DB3(1) = 4.D0*R1 -2.D0*R2 -2.D0*R3
         DB3(2) = 4.D0*R2 -2.D0*R3 -2.D0*R1
         DB3(3) = 4.D0*R3 -2.D0*R1 -2.D0*R2
         DB3(4) = 0.5D0*DB3(1)/B3B
         DB3(5) = 0.5D0*DB3(2)/B3B
         DB3(6) = 0.5D0*DB3(3)/B3B
         EXP1   = DEXP(-BETA1*R)
         EXP2   = DEXP(-BETA2*RSQ)
         EXP7   = DEXP(-BETA3*R)
         DEXP1  = -BETA1*EXP1
         DEXP2  = -2.D0*BETA2*R*EXP2
         DEXP7  = -BETA3*EXP7
C   DO THE VBNDA CALCULATIONS:
         B1    = B1A
         B12   = B1*B1
         B13   = B12*B1
         B14   = B13*B1
         B15   = B14*B1
         ASUM  = A11 +  A12*R +  A13*RSQ
         BSUM  = A21*B12 +  A22*B13 +  A23*B14 +  A24*B15
         CSUM  = A31*B1*EXP1 +  A32*B12*EXP2
         DSUM1 = A41*EXP1 +  A42*EXP2
         DSUM2 = A43*EXP1 +  A44*EXP2
         FSUM  = A51 +  A52*R +  A53*RSQ
         VB(1,1) = B1*ASUM*EXP1
         VB(1,2) = BSUM * EXP2
         VB(1,3) = B2*CSUM
         VB(1,4) = B1*B3*DSUM1 + B1*B3B*DSUM2
         VB(1,5) = B1* FSUM  *EXP7
         VBND(1) = VB(1,1)+VB(1,2)+VB(1,3)+VB(1,4)+VB(1,5)
C
         DASUM   = A12+2.D0*A13*R
         DBSUM   =  2.D0* A21*B1  + 3.D0* A22*B12
     .            + 4.D0* A23*B13 + 5.D0* A24*B14
         DDSUM1  =  A41*DEXP1 +  A42*DEXP2
         DDSUM2  =  A43*DEXP1 +  A44*DEXP2
         DFSUM   =  A52 +2.D0*A53*R
         DVB1(1) = DB1A(1)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
         DVB1(2) = DB1A(2)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
         DVB1(3) = DB1A(3)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
C
         DVB2(1) = DBSUM*DB1A(1)*EXP2 + BSUM*DEXP2
         DVB2(2) = DBSUM*DB1A(2)*EXP2 + BSUM*DEXP2
         DVB2(3) = DBSUM*DB1A(3)*EXP2 + BSUM*DEXP2
C
C CALCULATE THE VB3 DERIVATIVES:
         DVB3(1)=DB2(1)*CSUM + B2*(  A31*DB1A(1)*EXP1 +  A31*B1*DEXP1
     .                  +2.D0* A32*B1*DB1A(1)*EXP2 +  A32*B12*DEXP2)
         DVB3(2)=DB2(2)*CSUM + B2*(  A31*DB1A(2)*EXP1 +  A31*B1*DEXP1
     .                  +2.D0* A32*B1*DB1A(2)*EXP2 +  A32*B12*DEXP2)
         DVB3(3)=DB2(3)*CSUM + B2*(  A31*DB1A(3)*EXP1 +  A31*B1*DEXP1
     .                  +2.D0* A32*B1*DB1A(3)*EXP2 +  A32*B12*DEXP2)
C
C CALCULATE THE VB4 DERIVATIVES (MAY 27/90):
         DVB4(1)= DB1A(1)*B3 *DSUM1+  B1*DB3(1)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1A(1)*B3B*DSUM2 + B1*DB3(4)*DSUM2 + B1*B3B*DDSUM2
         DVB4(2)= DB1A(2)*B3 *DSUM1+  B1*DB3(2)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1A(2)*B3B*DSUM2 + B1*DB3(5)*DSUM2 + B1*B3B*DDSUM2
         DVB4(3)= DB1A(3)*B3 *DSUM1+  B1*DB3(3)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1A(3)*B3B*DSUM2 + B1*DB3(6)*DSUM2 + B1*B3B*DDSUM2
C
C CALCULATE THE VB5 DERIVATIVES:
         DVB5(1) = DB1A(1)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
         DVB5(2) = DB1A(2)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
         DVB5(3) = DB1A(3)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
C
C CALCULATE THE OVERALL DERIVATIVES:
         DVBNDA(1) = DVB1(1)+DVB2(1)+DVB3(1)+DVB4(1)+DVB5(1)
         DVBNDA(2) = DVB1(2)+DVB2(2)+DVB3(2)+DVB4(2)+DVB5(2)
         DVBNDA(3) = DVB1(3)+DVB2(3)+DVB3(3)+DVB4(3)+DVB5(3)
         VBNDA = VBND(1)
C
C---- NOW DO THE VBENDB CALCULATIONS --------
         B1    = B1B
         B12   = B1*B1
         B13   = B12*B1
         B14   = B13*B1
         B15   = B14*B1
         ASUM  = G11 +  G12*R +  G13*RSQ
         BSUM  = G21*B12 +  G22*B13 +  G23*B14 +  G24*B15
         CSUM  = G31*B1*EXP1 +  G32*B12*EXP2
         DSUM1 = G41*EXP1 +  G42*EXP2
         DSUM2 = G43*EXP1 +  G44*EXP2
         FSUM  = G51 +  G52*R +  G53*RSQ
         VB(2,1) = B1*ASUM*EXP1
         VB(2,2) = BSUM * EXP2
         VB(2,3) = B2*CSUM
         VB(2,4) = B1*B3*DSUM1 + B1*B3B*DSUM2
         VB(2,5) = B1* FSUM  *EXP7
         VBND(2) = VB(2,1)+VB(2,2)+VB(2,3)+VB(2,4)+VB(2,5)
C
         DASUM   = G12+2.D0*G13*R
         DBSUM   =  2.D0* G21*B1  + 3.D0* G22*B12
     .             +4.D0* G23*B13 + 5.D0* G24*B14
         DDSUM1  =  G41*DEXP1 +  G42*DEXP2
         DDSUM2  =  G43*DEXP1 +  G44*DEXP2
         DFSUM   =  G52 +2.D0*G53*R
         DVB1(1) = DB1B(1)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
         DVB1(2) = DB1B(2)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
         DVB1(3) = DB1B(3)*ASUM*EXP1 + B1*DASUM*EXP1 +B1*ASUM*DEXP1
C
         DVB2(1) = DBSUM*DB1B(1)*EXP2 + BSUM*DEXP2
         DVB2(2) = DBSUM*DB1B(2)*EXP2 + BSUM*DEXP2
         DVB2(3) = DBSUM*DB1B(3)*EXP2 + BSUM*DEXP2
C
C CALCULATE THE VB3 DERIVATIVES:
         DVB3(1)=DB2(1)*CSUM + B2*(  G31*DB1B(1)*EXP1 +  G31*B1*DEXP1
     .                  +2.D0* G32*B1*DB1B(1)*EXP2 +  G32*B12*DEXP2)
         DVB3(2)=DB2(2)*CSUM + B2*(  G31*DB1B(2)*EXP1 +  G31*B1*DEXP1
     .                  +2.D0* G32*B1*DB1B(2)*EXP2 +  G32*B12*DEXP2)
         DVB3(3)=DB2(3)*CSUM + B2*(  G31*DB1B(3)*EXP1 +  G31*B1*DEXP1
     .                  +2.D0* G32*B1*DB1B(3)*EXP2 +  G32*B12*DEXP2)
C
C CALCULATE THE VB4 DERIVATIVES (MAY 27/90):
         DVB4(1)= DB1B(1)*B3 *DSUM1+  B1*DB3(1)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1B(1)*B3B*DSUM2 + B1*DB3(4)*DSUM2 + B1*B3B*DDSUM2
         DVB4(2)= DB1B(2)*B3 *DSUM1+  B1*DB3(2)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1B(2)*B3B*DSUM2 + B1*DB3(5)*DSUM2 + B1*B3B*DDSUM2
         DVB4(3)= DB1B(3)*B3 *DSUM1+  B1*DB3(3)*DSUM1 + B1*B3 *DDSUM1
     .          + DB1B(3)*B3B*DSUM2 + B1*DB3(6)*DSUM2 + B1*B3B*DDSUM2
C
C CALCULATE THE VB5 DERIVATIVES:
         DVB5(1) = DB1B(1)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
         DVB5(2) = DB1B(2)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
         DVB5(3) = DB1B(3)*FSUM*EXP7 + B1*DFSUM*EXP7 + B1*FSUM*DEXP7
C
C CALCULATE THE OVERALL DERIVATIVES:
         DVBNDB(1) = DVB1(1)+DVB2(1)+DVB3(1)+DVB4(1)+DVB5(1)
         DVBNDB(2) = DVB1(2)+DVB2(2)+DVB3(2)+DVB4(2)+DVB5(2)
         DVBNDB(3) = DVB1(3)+DVB2(3)+DVB3(3)+DVB4(3)+DVB5(3)
         VBNDB = VBND(2)
C
C  NOW CALCULATE THE CBEND CORRECTION TERMS:
C  CBNDA USES THE B1A FORMULA AND CBNDB USES THE B1B FORMULA
      IF(ICOMPC.EQ.0) RETURN
      SUMT  = T(1) + T(2) + T(3)
      RCU   = RSQ*R
      P     = R1*R2*R3
      PSQ   = P*P
      PCU   = PSQ*P
      DP(1) = R2*R3
      DP(2) = R3*R1
      DP(3) = R1*R2
      CBNDS(1)  = 0.D0
      CBNDS(2)  = 0.D0
      DCBNDA(1) = 0.D0
      DCBNDA(2) = 0.D0
      DCBNDA(3) = 0.D0
      DCBNDB(1) = 0.D0
      DCBNDB(2) = 0.D0
      DCBNDB(3) = 0.D0
C  CALCULATE EXPONENTIALS AND DERIVATIVES (COMMON TO CBNDA AND CBNDB):
            EXP7  = DEXP( -BETA2*RCU )
            DEXP7 = -3.D0*BETA2*RSQ*EXP7
C ----- CALCULATE THE CBNDA CORRECTION TERM ----------------
       B1    = B1A
       B12   = B1*B1
       B13   = B12*B1
       B14   = B13*B1
       B15   = B14*B1
       ASUM  = C11 + C12*R + C13*RSQ + C14/R + C15/RSQ
       BSUM  = C21*B12 + C22*B13 + C23*B14 + C24*B15
       CSUM  = C31*B1 *EXP1  + C32*B12*EXP2
       DSUM1 = C41*EXP1 + C42*EXP2
       DSUM2 = C43*EXP1 + C44*EXP2
       FSUM  = CX1 + C52*R + C53*RSQ
       GSUM  = C61 + C62/R + C63/RSQ
       AASUM = C71 + C72*P + C73*PSQ + C74/P + C75/PSQ
       FFSUM =       C81*P + C82*PSQ + C84/PSQ
       DASUM = C12 + 2.D0*C13*R -C14/RSQ -2.D0*C15/RCU
       DBSUM = 2.D0*C21*B1 +3.D0*C22*B12 +4.D0*C23*B13 +5.D0*C24*B14
       DDSUM1= C41*DEXP1 + C42*DEXP2
       DDSUM2= C43*DEXP1 + C44*DEXP2
       DFSUM = C52 + 2.D0*C53*R
       DGSUM = -C62/RSQ - 2.D0*C63/RCU
       DAASUM = C72 +2.D0*C73*P -C74/PSQ -2.D0*C75/PCU
       DFFSUM = C81 + 2.D0*C82*P -2.D0*C84/PCU
         CB(1,1)  = B1*ASUM * EXP1  /P
         CB(1,2)  = BSUM * EXP2
         CB(1,3)  = B2*CSUM
         CB(1,4)  = B1*B3*DSUM1 + B1*B3B*DSUM2
         CB(1,5)  = B1 * FSUM * EXP7 /P
         CB(1,6)  = B1 * GSUM * EXP7
         CB(1,7)  = B1 * AASUM * EXP2
         CB(1,8)  = B1 * FFSUM * EXP7
         CBNDS(1) = CB(1,1)+CB(1,2)+CB(1,3)+CB(1,4)+CB(1,5)
     .                     +CB(1,6)+CB(1,7)+CB(1,8)
C       CALCULATE THE DERIVATIVES:
         DCB1(1) = DB1A(1)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(1)/PSQ
         DCB1(2) = DB1A(2)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(2)/PSQ
         DCB1(3) = DB1A(3)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(3)/PSQ
C
         DCB2(1) = DBSUM*DB1A(1)*EXP2 + BSUM*DEXP2
         DCB2(2) = DBSUM*DB1A(2)*EXP2 + BSUM*DEXP2
         DCB2(3) = DBSUM*DB1A(3)*EXP2 + BSUM*DEXP2
C
         DCB3(1) = DB2(1)*CSUM + B2*( C31*DB1A(1)*EXP1 +C31*B1*DEXP1
     .            +C32 *2.D0*B1*DB1A(1)*EXP2 + C32 *B12*DEXP2 )
         DCB3(2) = DB2(2)*CSUM + B2*( C31 *DB1A(2)*EXP1 +C31 *B1*DEXP1
     .            +C32 *2.D0*B1*DB1A(2)*EXP2 + C32 *B12*DEXP2 )
         DCB3(3) = DB2(3)*CSUM + B2*( C31 *DB1A(3)*EXP1 +C31 *B1*DEXP1
     .            +C32 *2.D0*B1*DB1A(3)*EXP2 + C32 *B12*DEXP2 )
C          DCB4 EQUATIONS MAY 27/90:
         DCB4(1) = DB1A(1)*B3 *DSUM1 + B1*DB3(1)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1A(1)*B3B*DSUM2 + B1*DB3(4)*DSUM2 + B1*B3B*DDSUM2
         DCB4(2) = DB1A(2)*B3 *DSUM1 + B1*DB3(2)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1A(2)*B3B*DSUM2 + B1*DB3(5)*DSUM2 + B1*B3B*DDSUM2
         DCB4(3) = DB1A(3)*B3 *DSUM1 + B1*DB3(3)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1A(3)*B3B*DSUM2 + B1*DB3(6)*DSUM2 + B1*B3B*DDSUM2
C          DCB5 EQUATIONS MAY 27/90: (CORRECTED JUN01)
         DCB5(1) = DB1A(1)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(1)/PSQ
         DCB5(2) = DB1A(2)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(2)/PSQ
         DCB5(3) = DB1A(3)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(3)/PSQ
C
         DCB6(1) = DB1A(1)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
         DCB6(2) = DB1A(2)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
         DCB6(3) = DB1A(3)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
C
         DCB7(1) = DB1A(1)*AASUM*EXP2 + B1*DAASUM*DP(1)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB7(2) = DB1A(2)*AASUM*EXP2 + B1*DAASUM*DP(2)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB7(3) = DB1A(3)*AASUM*EXP2 + B1*DAASUM*DP(3)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB8(1) = DB1A(1)*FFSUM*EXP7  +B1*DFFSUM*DP(1)*EXP7
     .                                +B1* FFSUM*DEXP7
         DCB8(2) = DB1A(2)*FFSUM*EXP7  +B1*DFFSUM*DP(2)*EXP7
     .                                +B1* FFSUM*DEXP7
         DCB8(3) = DB1A(3)*FFSUM*EXP7  +B1*DFFSUM*DP(3)*EXP7
     .                                +B1* FFSUM*DEXP7
           DCBNDS(1,1) = DCB1(1) +DCB2(1) +DCB3(1) +DCB4(1) +DCB5(1)
     .                  +DCB6(1) +DCB7(1) +DCB8(1)
           DCBNDS(1,2) = DCB1(2) +DCB2(2) +DCB3(2) +DCB4(2) +DCB5(2)
     .                  +DCB6(2) +DCB7(2) +DCB8(2)
           DCBNDS(1,3) = DCB1(3) +DCB2(3) +DCB3(3) +DCB4(3) +DCB5(3)
     .                  +DCB6(3) +DCB7(3) +DCB8(3)
C
C ----- CALCULATE THE CBNDB CORRECTION TERM ----------------
       B1    = B1B
       B12   = B1*B1
       B13   = B12*B1
       B14   = B13*B1
       B15   = B14*B1
       ASUM  = D11 + D12*R + D13*RSQ + D14/R + D15/RSQ
       BSUM  = D21*B12 + D22*B13 + D23*B14 + D24*B15
       CSUM  = D31*B1 *EXP1  + D32*B12*EXP2
       DSUM1 = D41*EXP1 + D42*EXP2
       DSUM2 = D43*EXP1 + D44*EXP2
       FSUM  = DX1 + D52*R + D53*RSQ
       GSUM  = D61 + D62/R + D63/RSQ
       AASUM = D71 + D72*P + D73*PSQ + D74/P + D75/PSQ
       FFSUM =       D81*P + D82*PSQ + D84/PSQ
       DASUM = D12 + 2.D0*D13*R -D14/RSQ -2.D0*D15/RCU
       DBSUM = 2.D0*D21*B1 +3.D0*D22*B12 +4.D0*D23*B13 +5.D0*D24*B14
       DDSUM1= D41*DEXP1 + D42*DEXP2
       DDSUM2= D43*DEXP1 + D44*DEXP2
       DFSUM = D52 + 2.D0*D53*R
       DGSUM = -D62/RSQ - 2.D0*D63/RCU
       DAASUM = D72 +2.D0*D73*P -D74/PSQ -2.D0*D75/PCU
       DFFSUM = D81 + 2.D0*D82*P -2.D0*D84/PCU
         CB(2,1)  = B1*ASUM * EXP1  /P
         CB(2,2)  = BSUM * EXP2
         CB(2,3)  = B2*CSUM
         CB(2,4)  = B1*B3*DSUM1 + B1*B3B*DSUM2
         CB(2,5)  = B1 * FSUM * EXP7 /P
         CB(2,6)  = B1 * GSUM * EXP7
         CB(2,7)  = B1 * AASUM * EXP2
         CB(2,8)  = B1 * FFSUM * EXP7
         CBNDS(2) = CB(2,1)+CB(2,2)+CB(2,3)+CB(2,4)+CB(2,5)
     .                     +CB(2,6)+CB(2,7)+CB(2,8)
C       CALCULATE THE DERIVATIVES:
         DCB1(1) = DB1B(1)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(1)/PSQ
         DCB1(2) = DB1B(2)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(2)/PSQ
         DCB1(3) = DB1B(3)*ASUM*EXP1/P + B1*DASUM*EXP1/P
     .                +B1*ASUM*DEXP1/P - B1*ASUM*EXP1*DP(3)/PSQ
C
         DCB2(1) = DBSUM*DB1B(1)*EXP2 + BSUM*DEXP2
         DCB2(2) = DBSUM*DB1B(2)*EXP2 + BSUM*DEXP2
         DCB2(3) = DBSUM*DB1B(3)*EXP2 + BSUM*DEXP2
C
         DCB3(1)= DB2(1)*CSUM + B2*( D31 *DB1B(1)*EXP1 +D31 *B1*DEXP1
     .           +D32 *2.D0*B1*DB1B(1)*EXP2 + D32 *B12*DEXP2 )
         DCB3(2)= DB2(2)*CSUM + B2*( D31 *DB1B(2)*EXP1 +D31 *B1*DEXP1
     .           +D32 *2.D0*B1*DB1B(2)*EXP2 + D32 *B12*DEXP2 )
         DCB3(3)= DB2(3)*CSUM + B2*( D31 *DB1B(3)*EXP1 +D31 *B1*DEXP1
     .           +D32 *2.D0*B1*DB1B(3)*EXP2 + D32 *B12*DEXP2 )
C          DCB4 EQUATIONS MAY 27/90:
         DCB4(1) = DB1B(1)*B3 *DSUM1 + B1*DB3(1)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1B(1)*B3B*DSUM2 + B1*DB3(4)*DSUM2 + B1*B3B*DDSUM2
         DCB4(2) = DB1B(2)*B3 *DSUM1 + B1*DB3(2)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1B(2)*B3B*DSUM2 + B1*DB3(5)*DSUM2 + B1*B3B*DDSUM2
         DCB4(3) = DB1B(3)*B3 *DSUM1 + B1*DB3(3)*DSUM1 + B1*B3 *DDSUM1
     .           + DB1B(3)*B3B*DSUM2 + B1*DB3(6)*DSUM2 + B1*B3B*DDSUM2
C          DCB5 EQUATIONS MAY 27/90:
         DCB5(1) = DB1B(1)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(1)/PSQ
         DCB5(2) = DB1B(2)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(2)/PSQ
         DCB5(3) = DB1B(3)*FSUM*EXP7/P + B1*DFSUM*EXP7/P
     .               + B1*FSUM*DEXP7/P - B1*FSUM*EXP7*DP(3)/PSQ
C
         DCB6(1) = DB1B(1)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
         DCB6(2) = DB1B(2)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
         DCB6(3) = DB1B(3)*GSUM*EXP7 + B1*DGSUM*EXP7 + B1*GSUM*DEXP7
C
         DCB7(1) = DB1B(1)*AASUM*EXP2 + B1*DAASUM*DP(1)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB7(2) = DB1B(2)*AASUM*EXP2 + B1*DAASUM*DP(2)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB7(3) = DB1B(3)*AASUM*EXP2 + B1*DAASUM*DP(3)*EXP2
     .                               + B1* AASUM*DEXP2
         DCB8(1) = DB1B(1)*FFSUM*EXP7  +B1*DFFSUM*DP(1)*EXP7
     .                                +B1* FFSUM*DEXP7
         DCB8(2) = DB1B(2)*FFSUM*EXP7  +B1*DFFSUM*DP(2)*EXP7
     .                                +B1* FFSUM*DEXP7
         DCB8(3) = DB1B(3)*FFSUM*EXP7  +B1*DFFSUM*DP(3)*EXP7
     .                                +B1* FFSUM*DEXP7
           DCBNDS(2,1) = DCB1(1) +DCB2(1) +DCB3(1) +DCB4(1) +DCB5(1)
     .                  +DCB6(1) +DCB7(1) +DCB8(1)
           DCBNDS(2,2) = DCB1(2) +DCB2(2) +DCB3(2) +DCB4(2) +DCB5(2)
     .                  +DCB6(2) +DCB7(2) +DCB8(2)
           DCBNDS(2,3) = DCB1(3) +DCB2(3) +DCB3(3) +DCB4(3) +DCB5(3)
     .                  +DCB6(3) +DCB7(3) +DCB8(3)
C
C  CALCULATE THE TOTAL DERIVATIVE FROM THE PIECES:
         DCBNDA(1) = DT(1) * CBNDS(1)    + SUMT * DCBNDS(1,1)
         DCBNDB(1) = DT(1) * CBNDS(2)    + SUMT * DCBNDS(2,1)
         DCBNDA(2) = DT(2) * CBNDS(1)    + SUMT * DCBNDS(1,2)
         DCBNDB(2) = DT(2) * CBNDS(2)    + SUMT * DCBNDS(2,2)
         DCBNDA(3) = DT(3) * CBNDS(1)    + SUMT * DCBNDS(1,3)
         DCBNDB(3) = DT(3) * CBNDS(2)    + SUMT * DCBNDS(2,3)
      CBNDA = SUMT*CBNDS(1)
      CBNDB = SUMT*CBNDS(2)
C  SOME DEBUGGING PRINT STATEMENTS:
CD    IF(IPR.GT.1)THEN
CD       WRITE(7,7650) B2,B3
CD       WRITE(7,7700) DB2,DB3
CD       WRITE(7,*)
CD       WRITE(7,*) 'VBEND VALUES :'
CD       K=1
CD       WRITE(7,7150) K,DVB1,DVB2,DVB3,DVB4,DVB5,DVBNDA
CD       WRITE(7,7155) (VB(1,I),I=1,5)
CD       K=2
CD       WRITE(7,7150) K,DVB1,DVB2,DVB3,DVB4,DVB5,DVBNDB
CD       WRITE(7,7155) (VB(2,I),I=1,5)
CD       WRITE(7,7100) VBNDA,VBNDB
CD       WRITE(7,*)
CD       WRITE(7,*) 'CBEND VALUES:'
CD       WRITE(7,*) 'C81,C81,C82=',C81,C81,C82
CD       WRITE(7,*) 'C91,C83,C84=',C91,C83,C84
CD       WRITE(7,*) 'D81,D81,D82=',D81,D81,D82
CD       WRITE(7,*) 'D91,D83,D84=',D91,D83,D84
CD       K=1
CD          WRITE(7,2020) K,(CB(1,J),J=1,9)
CD          WRITE(7,2033) SUMT,CBNDS(1)
CD       K=2
CD          WRITE(7,2020) K,(CB(K,J),J=1,9)
CD          WRITE(7,2033) SUMT,CBNDS(2)
CD       K=1
CD       WRITE(7,7152) K,DCB1,DCB2,DCB3,DCB4,DCB5,DCB6,
CD   .               DCB7,DCB8,DCB9,(DCBNDS(1,I),I=1,3)
CD       K=2
CD       WRITE(7,7152) K,DCB1,DCB2,DCB3,DCB4,DCB5,DCB6,
CD   .                 DCB7,DCB8,DCB9,(DCBNDS(K,I),I=1,3)
CD       WRITE(7,7200) DT,DCBNDA,DCBNDB
CD       WRITE(7,*) 'VBCB  EXIT -------------------------'
CD       WRITE(7,*)
CD    END IF
      RETURN
 2000 FORMAT(5X,'R1, R2, R3 = ',3(1X,F12.8))
 2010 FORMAT(5X,'B1A, B1B, B2, B3 = ',4(1X,G12.6))
 7100 FORMAT('    VBNDA = ',G12.6,'     VBNDB = ',G12.6)
 7650 FORMAT('    B2 =    ',G12.6,'       B3 =  ',G12.6)
 7700 FORMAT('    DB2 =   ',3(1X,G12.6),/,
     .       '    DB3 =   ',6(1X,G12.6))
 7150 FORMAT(' K=',I1,'     DERIVATIVES: ',/,
     .       ' DVB1  = ',3(1X,G16.10),/,
     .       ' DVB2  = ',3(1X,G16.10),/,
     .       ' DVB3  = ',3(1X,G16.10),/,
     .       ' DVB4  = ',3(1X,G16.10),/,
     .       ' DVB5  = ',3(1X,G16.10),/,
     .       ' DVBND = ',3(1X,G16.10))
 7155 FORMAT('  VB1 = ',G16.10,'  VB2 = ',G16.10,/,
     .       '  VB3 = ',G16.10,'  VB4 = ',G16.10,/,
     .       '  VB5 = ',G16.10)
 2020 FORMAT(5X,'K=',I1,' CB1,CB2,CB3= ',3(1X,G16.10),
     .     /,8X,' CB4,CB5,CB6= ',3(1X,G16.10),
     .     /,8X,' CB7,CB8,CB9= ',3(1X,G16.10))
 2033 FORMAT(5X,'SUMT = ',G12.6 ,'  CBNDS(K) = ',G12.6)
 7152 FORMAT('SUBR.CBEND:   K=',I1,'     DERIVATIVES: ',/,
     .       '  DCB1  = ',3(1X,G18.12),/,
     .       '  DCB2  = ',3(1X,G18.12),/,
     .       '  DCB3  = ',3(1X,G18.12),/,
     .       '  DCB4  = ',3(1X,G18.12),/,
     .       '  DCB5  = ',3(1X,G18.12),/,
     .       '  DCB6  = ',3(1X,G18.12),/,
     .       '  DCB7  = ',3(1X,G18.12),/,
     .       '  DCB8  = ',3(1X,G18.12),/,
     .       '  DCB9  = ',3(1X,G18.12),/,
     .       '  DCBND = ',3(1X,G18.12))
 7200 FORMAT('  DT    = ',3(1X,G18.12),/,
     .       '  DCBNDA= ',3(1X,G18.12),/,
     .       '  DCBNDB= ',3(1X,G18.12))
 6000 FORMAT(' FROM SUBR.B1AB:  R=',3(1X,F9.6))
 6010 FORMAT('    B1A = ',F16.10,'     B1B = ',F16.10)
 6020 FORMAT('    DB1A: ',3(1X,E12.6),/,'    DB1B: ',3(1X,E12.6))
 7000 FORMAT('    DC(J)/DR(I) DERIVATIVES: ',/,
     .    8X,3(1X,E12.6),/,8X,3(1X,E12.6),/,8X,3(1X,E12.6))
 7010 FORMAT('    RI2-RJ2-RK2: ',3(1X,E12.6),/,
     .       '       COSINES : ',3(1X,E12.6),/,
     .       '    12C**2 - 3 : ',3(1X,E12.6))
      END
C
      SUBROUTINE CHGEOM(R,IVALID)
C----------------------------------------------------------------------C
C APR21/95
C FIRST, CHECK THAT IT IS A VALID H3 GEOMETRY, WITHIN TOLERANCE "DERR":
C THIS TEST CORRECTED ON NOV23/93
C     GENERALLY, RLO + RMED > RHI
C     SOMETIMES, RLO + RMED = RHI (LINEAR GEOMETRY)
C     BUT IF     RLO + RMED < RHI THERE'S A PROBLEM
C
C ERROR1 ... CHECK THAT RLO+RMID>RHI
C ISTOP1 ... [0] WARNING [1]STOP CALCULATIONS
C
C ERROR2 ... CHECK THAT ALL R(I)'S ARE > 0.2 BOHR
C ISTOP2 ... [0] WARNING [1]STOP CALCULATIONS
C----------------------------------------------------------------------C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(DERR = 1.D-5)
      PARAMETER( ISTOP1 = 1 , ISTOP2 = 1 )
      DIMENSION R(3)
c       print*,r
      IVALID = 1
      RHI = DMAX1(R(1),R(2))
      IF(R(3).GE.RHI)THEN
         RMID = RHI
         RHI = R(3)
      ELSE
         RMID = DMAX1( R(3) , DMIN1(R(1),R(2)) )
      ENDIF
      RLO = DMIN1(R(1),R(2),R(3))
CX    IF(RLO+RMID.GT.RHI+DERR)THEN  {OLD CONDITION}
      IF(RLO+RMID+DERR.LT.RHI)THEN
         WRITE(6,*) ' RLONGEST          = ',RHI+DERR
         WRITE(6,*) ' RMIDDLE,RSHORTEST = ',RMID,RLO
         WRITE(6,*) 'WARNING: INVALID GEOMETRY R',R
c         IF(ISTOP1.GT.0) STOP ' STOP -- GEOMETRY ERROR '
C         IVALID = -1
      END IF
      IF(RLO.LT.0.2D0)THEN
CD       WRITE(6,*) ' SHORTEST DISTANCE: ',RLO
         WRITE(6,*) 'WARNING: INVALID GEOMETRY RLO',R
c         IF(ISTOP2.GT.0) STOP ' STOP -- GEOMETRY ERROR '
C         IVALID = -2
      END IF
      RETURN
      END
