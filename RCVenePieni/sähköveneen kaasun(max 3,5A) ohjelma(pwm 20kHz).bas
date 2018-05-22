;S‰hkˆveneen kaasun (max 3,5A) ohjelma. Ohjelma on siis siihen versioon, miss‰
;k‰ytet‰‰n IC-moottorinohjainta L298N.
;
;20.8.2015
;
aloitus:

  setfreq m32

  pwmout pwmdiv4, B.2, 99, 0  ;20 kHz:n pwm. Max duty on nyt 400 pwmduty komennossa.



  symbol pakki = B.4 
  
  symbol eteen = B.3
  
  symbol kaasu = B.2
  
  symbol rcVastari = C.0
  
  symbol ledi = C.4
  
  
  ; Valitse kaikki seuraavista luvuista kymmenell‰ jaollisiksi niin helpottaa laskentaa jatkossa (ja ohjelma toimii
  ; oikein)
  symbol maxLukema = 1690       ;testaa ja laita t‰h‰n vastarilta tuleva suurin lukema, kun trimmi on s‰‰detty 
                               ;yl‰asentoon ja kaasu on t‰ysill‰(viel‰ ehk‰ n. 10:t‰ suurempi kuin havaittu lukema).
                                  
                                  
  symbol minLukema = 760       ;testaa ja laita t‰h‰n vastarilta tuleva pienin lukema, kun trimmi on s‰‰detty 
                               ;ala-asentoon ja pakki on t‰ysill‰(viel‰ ehk‰ n. 10:t‰ pienempi kuin havaittu lukema).
                                  
  symbol keskiAsema = 1210      ; Lukema, mik‰ vastaa haluttua pys‰ytys/keski-asemaa
  
  
  symbol taysiKaasu = 1570          ; Lukema, mik‰ vastaa haluttua t‰ytt‰ kaasua eteenp‰in
  
  symbol taysiPakki = 870         ; Lukema, mik‰ vastaa haluttua t‰ytt‰ kaasua pakilla
  
  
  
  
  
  
   
   w2 = keskiasema + 50
   
   w3 = keskiasema - 50
   
  
   b15 = 0
  

main:

   
   pulsin rcVastari, 1, w0

   readadc B.1, b16
   
   readadc B.5, b17
   
  ; sertxd(#b16,13,10)

  ; sertxd(#b17,13,10)
   
   
   
   if b16 > 22 or b17 > 22 then ylikuormitus
   
   
   
   if w0 < minLukema  or w0 > maxLukema then          
                           ; Jos pulssia ei tule ollenkaan niin w0 = 0. Pys‰ytet‰‰n t‰llˆin.
      
      if b15 < 9 then      ; Odotetaan kymmenen nollaa per‰kk‰in ennen kuin pys‰ytet‰‰n
                           ; Pys‰ytet‰‰n myˆs jos tulee jotain odottamatonta kymmenen
         inc b15           ; kertaa per‰kk‰in. 
         
         goto main
      
      endif

      b15 = 0

      low pakki

      low eteen

      pwmduty kaasu, 0 

    '  sertxd(#w0,13,10)

      goto main

   endif
   
   b15 = 0
   
   
   
   ;T‰h‰n kohti tultaessa on siis varmasti minLukema <= w0 <= maxLukema
   
   
   if w0 < taysiPakki then      
   
   
       w0 = taysiPakki                     
   
    
   endif
 
 
   if w0 > taysiKaasu then      
   
   
       w0 = taysiKaasu                     
  
    
   endif
   
   
   ;nyt ollaan siis varmasti v‰lill‰ taysiPakki <= w0 <= taysiKaasu.
   
  
   
   
   if w0 >= w3 and w0 <= w2 then  ; ollaan siis alueella jossa halutaan varmasti olla paikallaan
 
     ' w0 = 0                     ;merkkin‰ paikallaanolosta
 
      low pakki
    
      low eteen
    
      pwmduty kaasu, 0
 
    '  sertxd(#w0,13,10)
      
      
      
      goto main
 
   endif
   
   
   
   if w0 > w2 then
 
 
     low pakki
 
     high eteen
 
 
 
     w0 = w0 - w2 ; w0 on nyt v‰lill‰ 1,...,taysiKaasu - w2, nyt menn‰‰n eteenp‰in
 
    ; T‰m‰ pit‰‰ nyt osata skaalata v‰lille 1,...,400
    ; Pit‰‰ siis kertoa luvulla 400/w5(w5 m‰‰ritelty alla)
    ; Koska tiedet‰‰n ett‰ kaikki luvut ovat nyt jaollisia kymmenell‰, niin jako w5/10 menee tasan ja voidaan
    ; siis ensin kertoa 40:lla ja sitten jakaa w5/10:lla. N‰in s‰‰styt‰‰n ylivuodolta kertolaskussa.
    ; (Havaittiin, ett‰ suoraan 400:lla kerrottaessa tulisi ylivuoto.)
    
     w5 = taysiKaasu - w2
 
     w5 = w5/10
 
     w0 = w0 * 40
    
     w0 = w0/w5
    
    
     pwmduty kaasu, w0
    
   '  sertxd(#w0,13,10)
    
     goto main
 
   endif
   
   
  if w0 < w3 then
 
    low eteen
 
    high pakki
 
 
    w0 = w3 - w0; w0 on nyt v‰lill‰ 1,...,w3-taysiPakki. nyt menn‰‰n taaksep‰in
 
    
 
    ; T‰m‰ pit‰‰ nyt osata skaalata v‰lille 1,...,400
    ; Pit‰‰ siis kertoa luvulla 400/w6(Kun  m‰‰ritell‰‰n w6 = w3-taysiPakki)
    ; Koska tiedet‰‰n ett‰ kaikki luvut ovat nyt kymmenell‰ jaollisia, niin jako w6/10 menee tasan ja voidaan
    ; siis ensin kertoa 40:lla ja sitten jakaa w6/10:lla. N‰in s‰‰styt‰‰n ylivuodolta kertolaskussa.
    
    
    w6 = w3 - taysiPakki
 
    w6 = w6/10
 
    w0 = w0 * 40
    
    w0 = w0/w6
    
    
    pwmduty kaasu, w0
    
    'sertxd(#w0,13,10)
    
    goto main
 
   endif
   
   
   
   
ylikuormitus:

  low eteen, pakki

  pwmduty kaasu, 0
  
  for b18 = 0 to 4
  
  
     high ledi
     
     pause 4000
     
     low ledi
     
     pause 4000
  
  next b18 
  
  
  goto main 