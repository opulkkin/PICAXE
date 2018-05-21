
; Ohjelma,jossa on esim. pyritty rajoittamaan suunnanvaihtoa jos kaasu on pohjassa.


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
 
 
   pause 500

   ; Tehd‰‰n alkuun suojaus, et‰‰ kaasupoljin pit‰‰ lˆys‰t‰ ja vaihdin laittaa vapaalle ennen kuin 

   ; p‰‰st‰‰n etenem‰‰n
   
   
   do 
   
      readadc kaasuPoljin, b0   
   
   loop until kytkinEteen = 0 and kytkinTaakse = 0 and b0 < 30



main:

   
   low ajaEteenpain, ajaTaaksepain
   
 
   
   if kytkinEteen = 0 and kytkinTaakse = 0 then
   
      gosub parkki
      
   endif

   if kytkinEteen = 1 and kytkinTaakse = 0  then
   
      gosub eteen
      
   endif
   
   if kytkinEteen = 0 and kytkinTaakse = 1 then
   
      gosub taakse
      
   endif

   goto main
   
   
parkki:


   low ajaEteenpain, ajaTaaksepain
   
    
   
   do
     
     do
        readadc kaasuPoljin, b0    
   
        gosub kalibroi
   
        pwmduty kaasu, b1
   
        pause 10
   
        sertxd(#b1, 13, 10)
     
     loop until b0 < 30
   
   loop while kytkinEteen = 0 and kytkinTaakse = 0 
   
   pwmduty kaasu,0
   
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
   
   
   pwmduty kaasu,0
   
   low ajaTaaksepain, ajaEteenpain
   
   pause 1000
   
   do
   
      readadc kaasuPoljin, b0
   
   loop until b0 < 30
   
   
  
   
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
   
  
   pwmduty kaasu,0
   
   low ajaTaaksepain, ajaEteenpain
   
   pause 1000
   
   do
   
      readadc kaasuPoljin, b0
   
   loop until b0 < 30
   
   
   
   return
   
   
kalibroi:

   if b0 < 56 then
   
      b1 = 0
   
   else
   
      b1 =  b0 - 55
   
   endif

   return