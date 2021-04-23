! fitplane - fit a plane to a 2d data set, subtract it off

  subroutine fitplane(in, out, n, m)

      parameter (NTERMS=3)	
      parameter (MP=1000000)
      parameter (NPP=3)

      real*4  in(n,m), out(n,m)
      real*8  xd(MP),yd(MP),zd(MP),sig(MP),acshift(MP),dnshift(MP),s(MP)
      real*8  coef(NPP),v(NPP,NPP),u(MP,NPP),w(NPP)
      real*8  chisq

      integer icoef(10)
      common /coefcomm/icoef

!c  create a set of x and y locations
      nn=n/10
      mm=m/10
      k=0
      do i=1,nn
         do j=1,mm
            k=k+1
            xd(k)=i*10-5
            yd(k)=j*10-5
            zd(k)=in(i*10-5,j*10-5)
            sig(k)=1.
         end do
      end do
!c  fit using svd
      ma=3
      icoef(1)=1
      icoef(2)=2
      icoef(3)=3
      call svdfit(xd,yd,zd,sig,nn*mm,coef,ma,u,v,w,MP,NPP,chisq)
     write(*,*)'chi square: ',chisq
     write(*,*)'coefficients: '
     do j=1,ma
     write(*,*)j,coef(j)
     end do

!c  subtract fit from input data and return it through out
     do i=1,n
        do j=1,m
           fit=coef(3)*i+coef(2)*j+coef(1)
           out(i,j)=in(i,j)-fit
        end do
     end do

!      do n=1,nn
!c     acest=coef(6)*(xd(n)**2)+coef(5)*(yd(n)**2)+
!c     +              coef(4)*xd(n)*yd(n)+ 
!c     +              coef(3)*xd(n)+coef(2)*yd(n)+coef(1)
!         acest=coef(3)*xd(n)+coef(2)*yd(n)+coef(1)
!         acresidual(n)=acshift(n)-acest
!      end do

  return

end subroutine fitplane


	 subroutine funcs(x,y,afunc,ma)

         integer icoef(10)
         common /coefcomm/icoef


         real*8 afunc(ma),x,y
         real*8 cf(10)

         data cf( 1) /0./
         data cf( 2) /0./
         data cf( 3) /0./
         data cf( 4) /0./
         data cf( 5) /0./
         data cf( 6) /0./
         data cf( 7) /0./
         data cf( 8) /0./
         data cf( 9) /0./
         data cf( 10) /0./

        do i=1,ma
             cf(icoef(i))=1.
             afunc(i)=cf(6)*(x**2)+cf(5)*(y**2)+cf(4)*x*y+cf(3)*x+cf(2)*y+cf(1)
             cf(i)=0.
        end do

	return
	end    

      subroutine svdfit(x,y,z,sig,ndata,a,ma,u,v,w,mp,np,chisq)
      implicit real*8 (a-h,o-z)
      parameter(nmax=300000,mmax=6,tol=1.e-6)
      dimension x(ndata),y(ndata),z(ndata),sig(ndata),a(ma),v(np,np),u(mp,np),w(np),b(nmax),afunc(mmax)
!c      write(*,*)'evaluating basis functions...'
      do 12 i=1,ndata
        call funcs(x(i),y(i),afunc,ma)
        tmp=1./sig(i)
        do 11 j=1,ma
          u(i,j)=afunc(j)*tmp
11      continue
        b(i)=z(i)*tmp
12    continue
!c      write(*,*)'SVD...'
      call svdcmp(u,ndata,ma,mp,np,w,v)
      wmax=0.
      do 13 j=1,ma
        if(w(j).gt.wmax)wmax=w(j)
13    continue
      thresh=tol*wmax
!c	write(*,*)'eigen value threshold',thresh
      do 14 j=1,ma
!c	write(*,*)j,w(j)
        if(w(j).lt.thresh)w(j)=0.
14    continue
!c      write(*,*)'calculating coefficients...'
      call svbksb(u,w,v,ndata,ma,mp,np,b,a)
      chisq=0.
!c      write(*,*)'evaluating chi square...'
      do 16 i=1,ndata
        call funcs(x(i),y(i),afunc,ma)
        sum=0.
        do 15 j=1,ma
          sum=sum+a(j)*afunc(j)
15      continue
        chisq=chisq+((z(i)-sum)/sig(i))**2
16    continue
      return
      end

      subroutine svbksb(u,w,v,m,n,mp,np,b,x)
      implicit real*8 (a-h,o-z)
      parameter (nmax=100)
      dimension u(mp,np),w(np),v(np,np),b(mp),x(np),tmp(nmax)
      do 12 j=1,n
        s=0.
        if(w(j).ne.0.)then
          do 11 i=1,m
            s=s+u(i,j)*b(i)
11        continue
          s=s/w(j)
        endif
        tmp(j)=s
12    continue
      do 14 j=1,n
        s=0.
        do 13 jj=1,n
          s=s+v(j,jj)*tmp(jj)
13      continue
        x(j)=s
14    continue
      return
      end

      subroutine svdcmp(a,m,n,mp,np,w,v)
      implicit real*8 (a-h,o-z)
      parameter (nmax=100)
      dimension a(mp,np),w(np),v(np,np),rv1(nmax)
      g=0.0
      scale=0.0
      anorm=0.0
      do 25 i=1,n
        l=i+1
        rv1(i)=scale*g
        g=0.0
        s=0.0
        scale=0.0
        if (i.le.m) then
          do 11 k=i,m
            scale=scale+abs(a(k,i))
11        continue
          if (scale.ne.0.0) then
            do 12 k=i,m
              a(k,i)=a(k,i)/scale
              s=s+a(k,i)*a(k,i)
12          continue
            f=a(i,i)
            g=-sign(sqrt(s),f)
            h=f*g-s
            a(i,i)=f-g
            if (i.ne.n) then
              do 15 j=l,n
                s=0.0
                do 13 k=i,m
                  s=s+a(k,i)*a(k,j)
13              continue
                f=s/h
                do 14 k=i,m
                  a(k,j)=a(k,j)+f*a(k,i)
14              continue
15            continue
            endif
            do 16 k= i,m
              a(k,i)=scale*a(k,i)
16          continue
          endif
        endif
        w(i)=scale *g
        g=0.0
        s=0.0
        scale=0.0
        if ((i.le.m).and.(i.ne.n)) then
          do 17 k=l,n
            scale=scale+abs(a(i,k))
17        continue
          if (scale.ne.0.0) then
            do 18 k=l,n
              a(i,k)=a(i,k)/scale
              s=s+a(i,k)*a(i,k)
18          continue
            f=a(i,l)
            g=-sign(sqrt(s),f)
            h=f*g-s
            a(i,l)=f-g
            do 19 k=l,n
              rv1(k)=a(i,k)/h
19          continue
            if (i.ne.m) then
              do 23 j=l,m
                s=0.0
                do 21 k=l,n
                  s=s+a(j,k)*a(i,k)
21              continue
                do 22 k=l,n
                  a(j,k)=a(j,k)+s*rv1(k)
22              continue
23            continue
            endif
            do 24 k=l,n
              a(i,k)=scale*a(i,k)
24          continue
          endif
        endif
        anorm=max(anorm,(abs(w(i))+abs(rv1(i))))
25    continue
      do 32 i=n,1,-1
        if (i.lt.n) then
          if (g.ne.0.0) then
            do 26 j=l,n
              v(j,i)=(a(i,j)/a(i,l))/g
26          continue
            do 29 j=l,n
              s=0.0
              do 27 k=l,n
                s=s+a(i,k)*v(k,j)
27            continue
              do 28 k=l,n
                v(k,j)=v(k,j)+s*v(k,i)
28            continue
29          continue
          endif
          do 31 j=l,n
            v(i,j)=0.0
            v(j,i)=0.0
31        continue
        endif
        v(i,i)=1.0
        g=rv1(i)
        l=i
32    continue
      do 39 i=n,1,-1
        l=i+1
        g=w(i)
        if (i.lt.n) then
          do 33 j=l,n
            a(i,j)=0.0
33        continue
        endif
        if (g.ne.0.0) then
          g=1.0/g
          if (i.ne.n) then
            do 36 j=l,n
              s=0.0
              do 34 k=l,m
                s=s+a(k,i)*a(k,j)
34            continue
              f=(s/a(i,i))*g
              do 35 k=i,m
                a(k,j)=a(k,j)+f*a(k,i)
35            continue
36          continue
          endif
          do 37 j=i,m
            a(j,i)=a(j,i)*g
37        continue
        else
          do 38 j= i,m
            a(j,i)=0.0
38        continue
        endif
        a(i,i)=a(i,i)+1.0
39    continue
      do 49 k=n,1,-1
        do 48 its=1,30
          do 41 l=k,1,-1
            nm=l-1
            if ((abs(rv1(l))+anorm).eq.anorm)  go to 2
            if ((abs(w(nm))+anorm).eq.anorm)  go to 1
41        continue
1         c=0.0
          s=1.0
          do 43 i=l,k
            f=s*rv1(i)
            if ((abs(f)+anorm).ne.anorm) then
              g=w(i)
              h=sqrt(f*f+g*g)
              w(i)=h
              h=1.0/h
              c= (g*h)
              s=-(f*h)
              do 42 j=1,m
                y=a(j,nm)
                z=a(j,i)
                a(j,nm)=(y*c)+(z*s)
                a(j,i)=-(y*s)+(z*c)
42            continue
            endif
43        continue
2         z=w(k)
          if (l.eq.k) then
            if (z.lt.0.0) then
              w(k)=-z
              do 44 j=1,n
                v(j,k)=-v(j,k)
44            continue
            endif
            go to 3
          endif
          if (its.eq.30) pause 'no convergence in 30 iterations'
          x=w(l)
          nm=k-1
          y=w(nm)
          g=rv1(nm)
          h=rv1(k)
          f=((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y)
          g=sqrt(f*f+1.0)
          f=((x-z)*(x+z)+h*((y/(f+sign(g,f)))-h))/x
          c=1.0
          s=1.0
          do 47 j=l,nm
            i=j+1
            g=rv1(i)
            y=w(i)
            h=s*g
            g=c*g
            z=sqrt(f*f+h*h)
            rv1(j)=z
            c=f/z
            s=h/z
            f= (x*c)+(g*s)
            g=-(x*s)+(g*c)
            h=y*s
            y=y*c
            do 45 nm=1,n
              x=v(nm,j)
              z=v(nm,i)
              v(nm,j)= (x*c)+(z*s)
              v(nm,i)=-(x*s)+(z*c)
45          continue
            z=sqrt(f*f+h*h)
            w(j)=z
            if (z.ne.0.0) then
              z=1.0/z
              c=f*z
              s=h*z
            endif
            f= (c*g)+(s*y)
            x=-(s*g)+(c*y)
            do 46 nm=1,m
              y=a(nm,j)
              z=a(nm,i)
              a(nm,j)= (y*c)+(z*s)
              a(nm,i)=-(y*s)+(z*c)
46          continue
47        continue
          rv1(l)=0.0
          rv1(k)=f
          w(k)=x
48      continue
3       continue
49    continue
      return
      end
