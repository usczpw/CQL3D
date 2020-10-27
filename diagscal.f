c
c
      subroutine diagscal(k)
      implicit integer (i-n), real*8 (a-h,o-z)

c..................................................................
c     This routine scales the distribution function to maintain
c     FSA constant density, or given time-dependent density. 
c     It is used only if lbdry(k)="scale" or "consscal" (which uses
c     conservative differencing at v=0 and scaling of density).
cyup140806: Prior, it was only enabled for lbdry(k)="scale".
c..................................................................
      include 'param.h'
      include 'comm.h'
CMPIINSERT_INCLUDE     

      ratio(k,lr_)=1.
cyup+bh140806: Enable new "consscal" option
      if (lbdry(k).ne."scale" .and. lbdry(k).ne."consscal") return

c..................................................................
c     Compute the new density..
c..................................................................

      call dcopy(iyjx2,f(0,0,k,l_),1,temp2(0,0),1) !Copy f(i,j) to temp2 and temp1
      call dcopy(iyjx2,temp2(0,0),1,temp1(0,0),1)
      call bcast(tam1,zero,jx)
      call bcast(tam4,zero,jx)

      ! Now integrate over d3v to find n0 and <n>
      do 1 i=1,iy
        do 2 j=1,jx
            if(temp1(i,j).gt.zero) then
               tam1(j)=tam1(j)+temp2(i,j)*cynt2(i,l_) !for n0 (midplane)
               tam4(j)=tam4(j)+vptb(i,lr_)*temp2(i,j)*cynt2(i,l_) !<n> ZOW only
            endif
 2      continue
 1    continue
      gn=0.d0
      sden=0.
      do 3 j=1,jx
          gn=gn+tam1(j)*cint2(j) !  n0 == Midplane density
          sden=sden+tam4(j)*cint2(j)*one_  ! <n> ZOW only
 3    continue

c..................................................................
c     Determine the velocity mesh point j such that for electron
c     runaway calculations the distribution density up to x(j)
c     is held constant. Used only for lbdry(k)="fixed" calculations.
c     This option is currently inoperable. 
c..................................................................

      j=jx
c     esfac=1.
c     if (k .ne. kelecg) go to 21
c     evol=esfac*sqrt(2.)*vth(kelec,lr_)/sqrt(abs(eoved))
c     do 20 j=1,jx
c     if (x(j)*vnorm .gt. evol) go to 21
c20   continue
c21   continue

c..................................................................
c     runden is the new density - will be used in denominator
c     of scale factor.
c..................................................................

      if ( j .gt. jx) j=jx
      runden=0.
      do 24 jj=1,j
        runden=runden+tam4(jj)*cint2(jj)*one_ !<n> ZOW only
 24   continue
 
c      write(*,'(a,2i3,4e12.5)')'k,lr,xlndn00(k,lr),runden,sden,gn=',
c     +                          k,lr_,xlndn00(k,lr_),runden,sden,gn
     
c..................................................................
c     If time-dependent density, add Maxwellian particles (at present
c     temperature or temp_den.ne.0.) to achieve reden(k,lr_).
c     Else, scale f to original density.
c..................................................................

cYuP,BH180918: enables proper treatment of spline-t profile option, 
cYuP,BH180918: adding enein_t
      if ( (nbctime.gt.0 .and. 
     &       (redenc(1,k).ne.zero .or. enein_t(1,k,1).ne.zero) ) 
     &   .or.
     &     ( (imp_depos_method.ne.'disabled').and.
     &       (k.eq.kelecg .or. k.eq.kelecm)          )
     &                              ) then
         !YuP[2020-06-24] Changed (gamafac.eq."hesslow") to (imp_depos_method.ne.'disabled')
         !   [a more general logic]
         ! Note: temp() and reden() are updated at each time step 
         ! in subr.profiles()
         if (temp_den.ne.zero) then
            temp_ad=temp_den ! set in namelist
         else
            temp_ad=temp(k,lr_)
         endif
         thta=fmass(k)*clite2/(temp_ad*ergtkev)
         do j=1,jx
            swwtemp=exp(-gamm1(j)*thta)
            do i=1,iy
               temp1(i,j)=swwtemp
            enddo
         enddo
         call bcast(tam1,zero,jx)
         do i=1,iy
            do j=1,jx
               tam1(j)=tam1(j)+vptb(i,lr_)*temp1(i,j)*cynt2(i,l_)
            enddo
         enddo
         
         sden1=0.
         do j=1,jx
            sden1=sden1+tam1(j)*cint2(j)
         enddo

         sden1=sden1/zmaxpsi(lr_)
 
         ratio1=(reden(k,lr_)-runden/zmaxpsi(lr_))/sden1
         !reden= n0_new is the new (target) density,
         !runden/zmaxpsi is the old n0_old (based on present f)
         do j=1,jx
            do i=1,iy
               f(i,j,k,l_)=f(i,j,k,l_)+ratio1*temp1(i,j)
               !Basically, this adjustment is
               ! f_new = f_old + (n_new-n_old)* f_cold/n_cold
               ! where f_cold/n_cold = temp1()/integral(temp1)
               ! and f_cold is set with T=temp_ad .
               ! Verify: Integrate both sides in d3v:
               ! n_new = n_old + (n_new-n_old)* n_cold/n_cold
               ! n_new = n_new
            enddo
         enddo ! j
         ! Verify: integrate f_new over d3v to find n0 and <n>
         call dcopy(iyjx2,f(0,0,k,l_),1,temp2(0,0),1)
         call bcast(tam4,zero,jx)
         do i=1,iy
         do j=1,jx
            if(temp2(i,j).gt.zero) then
               tam4(j)=tam4(j)+vptb(i,lr_)*temp2(i,j)*cynt2(i,l_) !<n>
            endif
            !Danger:  Can the new f() be pulled to negative values?
         enddo
         enddo
         sden_new=0.
         do j=1,jx
          sden_new=sden_new+tam4(j)*cint2(j)*one_  ! <n>new
         enddo
CMPIINSERT_IF_RANK_EQ_0
         WRITE(*,'(a,3i4,4e17.9)')
     &   'diagscal: n,k,lr=; f is adjusted. ratio1, nold, nnew,reden=',
     &              n,k,lr_,  ratio1, 
     &     runden/zmaxpsi(lr_), sden_new/zmaxpsi(lr_), reden(k,l_) 
CMPIINSERT_ENDIF_RANK
         
      else  !---> nbctime=0 (not a time-dependent profile)
      
         ratio(k,lr_)=xlndn00(k,lr_)/runden ! field-line-aver <n>
         call dscal(iyjx2,ratio(k,lr_),f(0,0,k,l_),1) !rescale f
CMPIINSERT_IF_RANK_EQ_0
         if (ioutput(1).ge.1) then !YuP[2020] Useful diagnostic printout
         !WRITE(*,'(a,3i4,3e13.5)')'diagscal: n,k,lr,xlndn00,runden,gn',
      !+                               n,k,lr_,xlndn00(k,lr_),runden,gn
         WRITE(*,'(a,3i4,e16.9)')
     &   'diagscal: n,k,lr=;  f is rescaled by ratio()=',
     &              n,k,lr_,  ratio(k,lr_) 
         endif
CMPIINSERT_ENDIF_RANK
         ! Note: it is not always a good idea to rescale the distr.func.
         ! Example: When there is a large-power NBI source, 
         ! comparing to the initial background 
         ! set in cqlinput. The value of xlndn00 
         ! (in ratio(k,lr_)=xlndn00(k,lr_)/runden) is based 
         ! on the initial density, so it does not include particles from NBI.
         ! And the value of runden (or sden) does include all sources.
         ! In such a case, it is better to use lbdry(k)="conserv"
      endif

      return
      end
