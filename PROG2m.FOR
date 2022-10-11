c *** Extreme value statistical analysis *******************************
c                                2022/10/08 Modified by Katsuya Hirayama
c **********************************************************************
c 
c �g���̋ɒl��̓v���O����
c (���c�Ǜ��F�ϔg�H�w�@�`�p�\�����̑ϔg�݌v�C�����o�ŉ�C2008)
c 
c
      parameter (kcs=1000)    !ksc:�ɒl�������͌��̏����(1000)
      dimension x(kcs),fm(kcs),ym(kcs),rp(30) !rp(30:�Z�o�Č����Ԃ̌���(30)
      character point*50,prob( 9)*16
      data prob/'�ɒl�T�^���z    ','�ɒl�U�^(k=10/4)',
     +          '�ɒl�U�^(k=10/3)','�ɒl�U�^(k=10/2)',
     +          '�ɒl�U�^(k=10/1)','���C�u��(k=0.75)',
     +          '���C�u��(k=1.00)','���C�u��(k=1.40)',
     +          '���C�u��(k=2.00)'/

 9991 write(*,*) '�����̎�ނ�I��ł�������'
      write(*,*) '�ɑ�l�����@�F1'
      write(*,*) '�N�ő�l�����F2'
      read(*,*) ntype
      if( ntype.eq.1 )then
        open(10,file='input-1.txt',status='unknown') !����file
        open(20,file='output1.txt',status='unknown') !�o��file
      else if( ntype.eq.2 )then
        open(10,file='input-2.txt',status='unknown') !����file
        open(20,file='output2.txt',status='unknown') !�o��file
      else
        write(*,*) '1 �܂��� 2 ����͂��Ă�������'
        go to 9991
      end if

      call dtin(10,x,nn,nt,nx,ala,anu,tk,point,rp,nrp,itk1,itk2,
     +    hl1,hl2,ntype)
      call check1(x,nn,xm,xs)
      xi=(x(1)-xm)/xs

      call fout01(20,point,nx,nt,nn,itk1,itk2,tk,hl1,hl2,ala,anu,
     +    xm,xs)

      rrmax=0.0
      amirmn=100.0
      irr=0
      iamir=0
      do 10 kk=1,9 
      call ploting(nn,nt,kk,fm,ym)
      call suitei(x,nn,   ym,aa,bb,rr)
      call dol05(kk,xi,nn,anu,xi05,ixi05)
      call dol95(kk,xi,nn,anu,xi95,ixi95)
      call rec(kk,nn,anu,rr,dr95,idr95)
      call mir(kk,nn,anu,rr,amir)
      call fout02(20,kk,prob(kk),ala,aa,bb,rr,nn,anu,xs,amir,rp,nrp,
     +     ixi05,ixi95,idr95)
      if(kk.le.9) then
      ixi=ixi05+ixi95+idr95
      if(ixi.eq.0.and.rr.gt.rrmax) then
      rrmax=rr
      irr=kk
      end if
      if(ixi.eq.0.and.amir.lt.amirmn) then
      amirmn=amir
      iamir=kk
      end if
      end if
   10 continue

      call fout03(20,prob,iamir,irr)

      close(10)
      close(20)

      stop
      end

csub �f�[�^�C���v�b�g
      subroutine dtin(io,x,nn,nt,nx,ala,anu,tk,point,rp,nrp,itk1,itk2,
     +    hl1,hl2,ntype)
      dimension x(*),rp(*)
      character form1*20,point*50

      read(io,*)
      read(io,*)
      read(io,*)
      read(io,'(a50)') point
      write(*,'(a50)') point
      read(io,'(2i5)') itk1,itk2
       tk=ifix(itk2-itk1+1.0001)
      read(io,'(i5,2f5.0)') nx,hl1,hl2
       if( hl1.gt.hl2 ) hl2 = hl1           !check
      read(io,'(a20)') form1
      read(io,form1) (x(i),i=1,nx)
      write(*,form1) (x(i),i=1,nx)

      read(io,'(i5)') nrp
      read(io,'(a20)') form1
      read(io,form1) (rp(i),i=1,nrp)

c �f�[�^��傫�����ɕ��ёւ���,
      do i=1,nx-1
      do j=i+1,nx
      if(x(i).lt.x(j)) then
      work=x(i)
      x(i)=x(j)
      x(j)=work
      end if
      end do
      end do

c �Ώۊ��ԁFtk
c �C���v�b�g�f�[�^���Fnx
c �ɑ�l�̃f�[�^���ihl1<�j�Fnt
c ���؂��̃f�[�^���ihl2<�j�Fnn
c ���ϔ������Fala=nt/tk
c �f�[�^�̑𗦁Fanu=nn/nt

      do i=1,nx
      if(x(i).ge.hl1) nt=i
      if(x(i).ge.hl2) nn=i
      end do
        if(ntype.eq.2)then                  !check
          if( nt.lt.nx ) tk = tk -(nx-nt)   !check
        end if                              !check
      ala=float(nt)/tk
      anu=float(nn)/float(nt)

      return
      end

csub �`�F�b�N�P
c xm�F���ϒl
c xs�F�s�ΕW���΍�
      subroutine check1(x,nn,xm,xs)
      dimension x(*)
      xm=0.0
      xx=0.0
      do i=1,nn
      xm=xm+x(i)
      xx=xx+x(i)*x(i)
      end do
      xm=xm/float(nn)
      ss=(xx-float(nn)*xm*xm)/float(nn-1)
      xs=sqrt(ss)
      return
      end

csub �ɒl���z�֐��̓��Ă͂�
      subroutine ploting(nn,nt,kk,fm,ym)
      dimension fm(*),ym(*),ak1(4),ak2(4)
      data ak1/ 0.4, 0.3, 0.2, 0.1/
      data ak2/0.75,1.00,1.40,2.00/

      if(kk.eq.1)  go to 10
      if(kk.le.5)  go to 20
      if(kk.le.9)  go to 30

c FT-I ( Gumbel )
   10 continue
      al=0.44
      be=0.12
      do i=1,nn
      fm(i)=1.0-(float(i)-al)/(float(nt)+be)
      ym(i)=-alog(-alog(fm(i)))
      end do
      go to 50
c FT-II
   20 continue
      ak=1.0/ak1(kk-1)
      al=0.44+0.52/ak
      be=0.12-0.11/ak
      do i=1,nn
      fm(i)=1.0-(float(i)-al)/(float(nt)+be)
      ym(i)=ak*((-alog(fm(i)))**(-1.0/ak)-1.0)
      end do
      go to 50
c Weibull
   30 continue
      ak=ak2(kk-5)
      al=0.20+0.27/sqrt(ak)
      be=0.20+0.23/sqrt(ak)
      do i=1,nn
      fm(i)=1.0-(float(i)-al)/(float(nt)+be)
      ym(i)=(-alog(1.0-fm(i)))**(1.0/ak)
      end do

   50 continue

      return
      end

csub �ŏ����@�ɂ��ꐔ�̐���E
      subroutine suitei(x,nn,   ym,aa,bb,rr)
      dimension x(*),ym(*),xm(1000)

      sx=0.0
      sy=0.0
      sxx=0.0
      syy=0.0
      sxy=0.0
      do i=1,nn
      xm(i)=x(i)

      sx=sx+xm(i)
      sy=sy+ym(i)
      sxx=sxx+xm(i)*xm(i)
      syy=syy+ym(i)*ym(i)
      sxy=sxy+xm(i)*ym(i)
      end do
      aa=(float(nn)*sxy-sx*sy)/(float(nn)*syy-sy*sy)
      bb=(sx-aa*sy)/float(nn)
      rr=(float(nn)*sxy-sx*sy)
     +   /sqrt((float(nn)*sxx-sx*sx)*(float(nn)*syy-sy*sy))
      return
      end

csub �Č��m���̐���
      subroutine saigen(ala,kk,aa,bb,rt,xr,yr)
      dimension ak1(4),ak2(4)
      data ak1/ 0.4, 0.3, 0.2, 0.1/
      data ak2/0.75,1.00,1.40,2.00/

      rp=rt

      if(kk.eq.1)  go to 10
      if(kk.le.5)  go to 20
      if(kk.le.9)  go to 30

c FT-I ( Gumbel )
   10 continue
      yr=-alog(-alog(1.0-1.0/(ala*rp)))
      xr=aa*yr+bb
      go to 50
c FT-II
   20 continue
      ak=1.0/ak1(kk-1)
      yr=ak*((-alog(1.0-1.0/(ala*rp)))**(-1.0/ak)-1.0)
      xr=aa*yr+bb
      go to 50
c Weibull
   30 continue
      ak=ak2(kk-5)
      yr=(alog(ala*rp))**(1.0/ak)
      xr=aa*yr+bb
      go to 50

   50 continue

      return
      end

csub �����c�n�k��i�T���j����
      subroutine dol05(kk,xi,nn,anu,xip,ixip)
      go to (1,2,3,4,5,6,7,8,9 ),kk
    1 continue
      aa=0.257+0.133*anu**2
      bb=0.452-0.118*anu**2
      cc=0.032
      go to 20
    2 continue
      aa=1.481-0.126*anu**0.25
      bb=-0.331-0.031*anu**2
      cc=0.192
      go to 20
    3 continue
      aa=1.025
      bb=-0.077-0.050*anu**2
      cc=0.143
      go to 20
    4 continue
      aa=0.700+0.060*anu**2
      bb=0.139-0.076*anu**2
      cc=0.100
      go to 20
    5 continue
      aa=0.424+0.088*anu**2
      bb=0.329-0.094*anu**2
      cc=0.061
      go to 20
    6 continue
      aa=0.534-0.162*anu
      bb=0.277+0.095*anu
      cc=0.065
      go to 20
    7 continue
      aa=0.308
      bb=0.423
      cc=0.037
      go to 20
    8 continue
      aa=0.192+0.126*anu**1.5
      bb=0.501-0.081*anu**1.5
      cc=0.018
      go to 20
    9 continue
      aa=0.050+0.182*anu**1.5
      bb=0.592-0.139*anu**1.5
      cc=0.0

   20 continue

      xip=aa+bb*alog(nn*1.0)+cc*(alog(nn*1.0))**2
      ixip=0
      if(xi.lt.xip) ixip=1

      return
      end

csub ����c�n�k��i�X�T���j����
      subroutine dol95(kk,xi,nn,anu,xip,ixip)
      go to (1,2,3,4,5,6,7,8,9 ),kk
    1 continue
      aa=-0.579+0.468*anu
      bb=1.496-0.227*anu**2
      cc=-0.038
      go to 20
    2 continue
      aa=4.653-1.076*anu**0.5
      bb=-2.047+0.307*anu**0.5
      cc=0.635
      go to 20
    3 continue
      aa=3.217-1.216*anu**0.25
      bb=-0.903+0.294*anu**0.25
      cc=0.427
      go to 20
    4 continue
      aa=0.599-0.038*anu**2
      bb=0.518-0.045*anu**2
      cc=0.210
      go to 20
    5 continue
      aa=-0.371+0.171*anu**2
      bb=1.283-0.133*anu**2
      cc=0.045
      go to 20
    6 continue
      aa=-0.256-0.632*anu**2
      bb=1.269+0.254*anu**2
      cc=0.037
      go to 20
    7 continue
      aa=-0.682
      bb=1.600
      cc=-0.045
      go to 20
    8 continue
      aa=-0.548+0.452*anu**0.5
      bb=1.521-0.184*anu
      cc=-0.065
      go to 20
    9 continue
      aa=-0.322+0.641*anu**0.5
      bb=1.414-0.326*anu
      cc=-0.069

   20 continue

      xip=aa+bb*alog(nn*1.0)+cc*(alog(nn*1.0))**2
      ixip=0
      if(xi.gt.xip) ixip=1

      return
      end

csub �q�d�b��ɂ����p����
      subroutine rec(kk,nn,anu,rr,dr95,idr95)
      go to (1,2,3,4,5,6,7,8,9 ),kk
    1 continue
      aa=-1.444
      bb=-0.2733-0.0414*anu**2.5
      cc=-0.045
      go to 20
    2 continue
      aa=-1.122-0.037*anu
      bb=-0.3298+0.0105*anu**0.25
      cc=0.016
      go to 20
    3 continue
      aa=-1.306-0.105*anu**1.5
      bb=-0.3001+0.0404*anu**0.5
      cc=0.0
      go to 20
    4 continue
      aa=-1.463-0.107*anu**1.5
      bb=-0.2716+0.0517*anu**0.25
      cc=-0.018
      go to 20
    5 continue
      aa=-1.490-0.073*anu
      bb=-0.2299-0.0099*anu**2.5
      cc=-0.034
      go to 20
    6 continue
      aa=-1.473-0.049*anu**2
      bb=-0.2181+0.0505*anu**2
      cc=-0.041
      go to 20
    7 continue
      aa=-1.433
      bb=-0.2679
      cc=-0.044
      go to 20
    8 continue
      aa=-1.312
      bb=-0.3356-0.0449*anu
      cc=-0.045
      go to 20
    9 continue
      aa=-1.188+0.073*anu**0.5
      bb=-0.4401-0.0846*anu**1.5
      cc=-0.039

   20 continue

      dr95=exp(aa+bb*alog(nn*1.0)+cc*(alog(nn*1.0))**2)
      dr=1.0-rr
      idr95=0
      if(dr.gt.dr95) idr95=1

      return
      end

csub �l�h�q��̌v�Z
      subroutine mir(kk,nn,anu,rr,amir)
      if(kk.eq.1) then
      aa=-2.364+0.054*anu**2.5
      bb=-0.2665-0.0457*anu**2.5
      cc=-0.044
      end if
      if(kk.eq.2) then
      aa=-2.470+0.015*anu**1.5
      bb=-0.1530-0.0052*anu**2.5
      cc=0.0
      end if
      if(kk.eq.3) then
      aa=-2.462-0.009*anu**2
      bb=-0.1933-0.0037*anu**2.5
      cc=-0.007
      end if
      if(kk.eq.4) then
      aa=-2.463
      bb=-0.2110-0.0131*anu**2.5
      cc=-0.019
      end if
      if(kk.eq.5) then
      aa=-2.437+0.028*anu**2.5
      bb=-0.2280-0.0300*anu**2.5
      cc=-0.033
      end if
      if(kk.eq.6) then
      aa=-2.435-0.168*anu**0.5
      bb=-0.2083+0.1074*anu**0.5
      cc=-0.047
      end if
      if(kk.eq.7) then
      aa=-2.355
      bb=-0.2612
      cc=-0.043
      end if
      if(kk.eq.8) then
      aa=-2.277+0.056*anu**0.5
      bb=-0.3169-0.0499*anu
      cc=-0.044
      end if
      if(kk.eq.9) then
      aa=-2.160+0.113*anu
      bb=-0.3788-0.0979*anu
      cc=-0.041
      end if

      drm=exp(aa+bb*alog(nn*1.0)+cc*(alog(nn*1.0))**2)
      amir=(1.0-rr)/drm
      return
      end

csub �Č��m�����v�ʂ̐M�����
      subroutine sigx(kk,nn,anu,xs,yr,sigxr)
      go to (1,2,3,4,5,6,7,8,9 ),kk
    1 continue
      aa=0.64*exp(9.0*(nn*1.0)**(-1.3)+0.93*(-alog(anu))**0.5)
      sigz=(1.0+aa*(yr-0.0+1.33*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    2 continue
      aa=1.27*exp(0.12*(alog(nn*anu**0.5/23.0))**2
     +   -0.24*(alog(anu/1.34))**2)
      sigz=(1.0+aa*(yr-0.3+2.3*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    3 continue
      aa=1.23*exp(0.09*(alog(nn*anu**0.5/25.0))**2
     +   -0.36*(alog(anu/0.66))**2)
      sigz=(1.0+aa*(yr-0.2+1.9*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    4 continue
      aa=1.34*exp(0.07*(alog(nn*anu**0.5/35.0))**2
     +   -0.41*(alog(anu/0.45))**2)
      sigz=(1.0+aa*(yr-0.1+1.6*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    5 continue
      aa=1.48*exp(0.06*(alog(nn*anu**0.5/60.0))**2
     +   -0.47*(alog(anu/0.34))**2)
      sigz=(1.0+aa*(yr-0.0+1.4*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    6 continue
      aa=1.65*exp(11.4*(nn*1.0)**(-1.3)-0.63*(-alog(anu))**0.5)
      sigz=(1.0+aa*(yr-0.0+1.15*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    7 continue
      aa=1.92*exp(11.4*(nn*1.0)**(-1.3)+0.00*(-alog(anu))**0.5)
      sigz=(1.0+aa*(yr-0.3+0.90*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    8 continue
      aa=2.05*exp(11.4*(nn*1.0)**(-1.3)+0.69*(-alog(anu))**0.5)
      sigz=(1.0+aa*(yr-0.4+0.72*alog(anu))**2)**0.5/sqrt(nn*1.0)
      go to 20
    9 continue
      aa=2.24*exp(11.4*(nn*1.0)**(-1.3)+1.34*(-alog(anu))**0.5)
      sigz=(1.0+aa*(yr-0.5+0.54*alog(anu))**2)**0.5/sqrt(nn*1.0)

   20 continue

      sigxr=sigz*xs

      return
      end

csub �t�@�C���o�́i���̂P�j
      subroutine fout01(io,point,nx,nt,nn,itk1,itk2,tk,hl1,hl2,ala,anu,
     +    xm,xs)
      character point*50

      write(io,'(a50)') point
      write(io,*)
      write(io,*)
      write(io,'(a20,i4,a4,i4,a2)') '���v���ԁ@�@�@�@�@�F',itk1,'�N�`',
     +    itk2,'�N'
      write(io,'(a20,f10.5,a2)') '�L�����v�N���@�@�@�F',tk,'�N'
      write(io,'(a20,f7.2)') '�ɑ�l�̉����@�@�@�F',hl1
      write(io,'(a20,f7.2)') '���؂�̒l�@�@�@�@�F',hl2
      write(io,'(a20,i5)') '���̓f�[�^���@�@�@�F',nx
      write(io,'(a20,i5)') '�ɑ�l�̃f�[�^���@�F',nt
      write(io,'(a20,i5)') '���؂��̃f�[�^���F',nn
      write(io,'(a20,f10.5)') '���ϔ������@�@�@�@�F',ala
      write(io,'(a20,f10.5)') '�f�[�^�̑𗦁@�@�@�F',anu
      write(io,'(a20,f10.5)') '���ϒl�@�@�@�@�@�@�F',xm
      write(io,'(a20,f10.5)') '�s�ΕW���΍��@�@�@�F',xs
      write(io,*)
      write(io,*)

      return
      end

csub �t�@�C���o�́i���̂Q�j
      subroutine fout02(io,kk,prob,ala,aa,bb,rr,nn,anu,xs,amir,rp,nrp,
     +           ixi05,ixi95,idr95)
      dimension rp(*)
      character prob*16,at*8,mark(0:1)*2
      data mark/'��','�~'/

      write(io,'(a14,a16,a4,f6.3,a4,f6.3)') '�ɒl���z�֐��F',prob
     1 ,'  A:',aa,'  B:',bb
      write(io,'(4x,a16,f8.5)') '���֌W���@�@�@�F',rr
      write(io,'(4x,a16,f8.5)') '�l�h�q�@�@�@�@�F',amir
      write(io,'(4x,a16,a2)') '�����c�n�k��F',mark(ixi05)
      write(io,'(4x,a16,a2)') '����c�n�k��F',mark(ixi95)
      write(io,'(4x,a16,a2)') '�q�d�b��@�@�F',mark(idr95)
      write(io,'(4x,8x,a8,6x,a10,2x,a14,8x,a8)')
     +  '�Č�����','����ϗ�','�Č��m�����v��','�W���΍�'
      at=' 1000 �N'
      do i=1,nrp
      call saigen(ala,kk,aa,bb,rp(i),xr,yr)
      call sigx(kk,nn,anu,xs,yr,sigxr)
      write(at(2:5),'(i4)') ifix(rp(i)+0.0001)
      write(io,'(4x,8x,a8,4(6x,f10.3))') at,yr,xr,sigxr
      end do
      write(io,*)

      return
      end

      subroutine fout03(io,prob,iamir,irr)
      character prob( 9)*16

      write(io,*)
      write(io,*)
      write(io,'(a32)') '�|�|�|�@�œK�ɒl���z�֐��@�|�|�|'
      write(io,*)
      if(iamir.eq.0) then
      write(io,'(5x,a28)') '�l�h�q�ɂ�锻��@�F�Y������'
      else
      write(io,'(5x,a20,a16)') '�l�h�q�ɂ�锻��@�F',prob(iamir)
      end if
      write(io,*)
      if(irr.eq.0) then
      write(io,'(5x,a28)') '���֌W���ɂ�锻��F�Y������'
      else
      write(io,'(5x,a20,a16)') '���֌W���ɂ�锻��F',prob(irr)
      end if

      return
      end
