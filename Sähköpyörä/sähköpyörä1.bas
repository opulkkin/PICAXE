
; Sähköpyörän kaasuun ohjelma, jossa potentiometrilla voi säätää kierroksia ja jossa
; tarkkaillaan koko ajan akun jännitettä ja pysäytetään.


alustus:

   pause 500
   
   disconnect        ' laitetaan ohjelmalatauksen tarkistus pois päältä, koska tästä
                     ' saattaa tulla ylimääräistä häiriötä...


   symbol kaasuSaadin = C.4
   
   symbol akunJannite = B.5
   
   symbol kaasu = B.2

   pwmout kaasu, 49, 0 ; 20 kHz:n pwm

    
   symbol akunRajaLukema = 175 ' 182 vastaa sähköpyörän piirissä n. 11,5 V akun jännitettä.
                               ' 176 vastaa sähköpyörän piirissä n. 11,0 V akun jännitettä.
   b0 = 0
   
   b1 = 0

   b2 = 0
 
 
 
aloitus:

   
   pwmduty kaasu, 0

   pause 2000

   ; Tehdään alkuun suojaus, etää kaasupoljin pitää löysätä ennen kuin 

   ; päästään etenemään
   
   
   do 
   
      readadc kaasuSaadin, b0   
   
   loop until b0 < 30



main:

   readadc kaasuSaadin, b0    
   
   readadc akunJannite, b2
   
   
   if b2 < akunRajaLukema then aloitus
   
   
   gosub kalibroi
   
   pwmduty kaasu, b1
   
   pause 10
   
   sertxd("kaasun saato: ", #b1, 13, 10)
   
   sertxd("akunJannite: ", #b2, 13, 10)
   
  ' pause 500

   goto main
   
   
kalibroi:

   if b0 < 56 then
   
      b1 = 0
   
   else
   
      b1 =  b0 - 55
   
   endif

   return