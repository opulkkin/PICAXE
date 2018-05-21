alustus:


   symbol kaasuPoljin = C.0
   
   symbol kytkinEteen = pinC.2
   
   symbol kytkinTaakse = pinC.4
   
   symbol ajaEteenpain = B.4

   symbol ajaTaaksepain = B.5
   
   symbol kaasu = B.2

   pwmout kaasu, 49, 0 ; 20 kHz:n pwm

   b0 = 0
   
   b1 = 0

 ;  b2 = 0

main:

   
   low ajaEteenpain, ajaTaaksepain
   
 ;  if b2 = 0 then
    
 ;   gosub parkki
      
 ;  endif
   
   if kytkinEteen = 0 and kytkinTaakse = 0 then
   
      gosub parkki
      
   endif

   if kytkinEteen = 1 and kytkinTaakse = 0  then
   
      gosub eteen
      
   endif
   
   if kytkinEteen = 0 and kytkinTaakse = 1  then
   
      gosub taakse
      
   endif

   goto main
   
   
parkki:

   low ajaEteenpain, ajaTaaksepain
   
   do
     
      readadc kaasuPoljin, b0    
   
      gosub kalibroi
   
      pwmduty kaasu, b1
   
      pause 10
   
      sertxd(#b1, 13, 10)
   
   loop while kytkinEteen = 0 and kytkinTaakse = 0 
   
 ;  do
   
 ;     readadc kaasuPoljin, b0 
      
 ;     pause 10
      
 ;  loop until b0 = 0              ;T‰m‰ lis‰tty uusimpana t‰h‰n. Pit‰isi est‰‰ suunnanvaihtamisen jos kaasupoljin
   					    ;ei ole vapautettuna, ja muutenkin pidet‰‰n n. 1s tauko.
   
   
;   b2 = 1
   
   return
   
   
eteen:

   low  ajaTaaksepain
   
   pause 100
   
   high ajaEteenpain
   
   do
     
      readadc kaasuPoljin, b0    
   
      gosub kalibroi
   
      pwmduty kaasu, b1
   
      pause 10
   
      sertxd(#b1, 13, 10)
   
   loop while kytkinEteen = 1 and kytkinTaakse = 0
   
 ;  low ajaTaaksepain, ajaEteenpain
   
 ;  pause 1000
   
 ;  b2 = 0
   
   return
   
   
taakse:

   low  ajaEteenpain
   
   pause 100
   
   high ajaTaaksepain
   
   do
     
      readadc kaasuPoljin, b0    
   
      gosub kalibroi
   
      pwmduty kaasu, b1
   
      pause 10
   
      sertxd(#b1, 13, 10)
   
   loop while kytkinEteen = 0 and kytkinTaakse = 1
   
  ; low ajaTaaksepain, ajaEteenpain
   
  ; pause 1000
   
   
 ;  b2 = 0
   
   return
   
   
kalibroi:

   if b0 < 56 then
   
      b1 = 0
   
   else
   
      b1 =  b0 - 55
   
   endif

   return