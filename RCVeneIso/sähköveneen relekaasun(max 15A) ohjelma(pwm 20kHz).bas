;S‰hkˆveneen kaasun (max 15A) ohjelma koekytkent‰versioon.
;
; 6.4.2017
;
; Piikkivirran mittaaminen voidaan j‰tt‰‰ kokonaan pois.

aloitus:

  setfreq m32

  pwmout pwmdiv4, B.2, 99, 0  ;20 kHz:n pwm. Max duty on nyt 400 pwmduty komennossa.



  symbol pakki = B.3 
  
  symbol kaasu = B.2  
  
  symbol rcVastari = C.0
  
  symbol akunJannitePin = B.1
  
  symbol piikkiVirtaLukemaPin = B.4
  
  symbol virtaLukemaPin = B.5
  
  symbol ledi = C.4
  
  
  ; Valitse kaikki seuraavista luvuista kymmenell‰ jaollisiksi niin helpottaa laskentaa jatkossa (ja ohjelma toimii
  ; oikein)
  symbol maxLukema = 1690       ;testaa ja laita t‰h‰n vastarilta tuleva suurin lukema, kun trimmi on s‰‰detty 
                               ;yl‰asentoon ja kaasu on t‰ysill‰(viel‰ ehk‰ n. 10:t‰ suurempi kuin havaittu lukema).
                                  
                                  
  symbol minLukema = 720       ;testaa ja laita t‰h‰n vastarilta tuleva pienin lukema, kun trimmi on s‰‰detty 
                               ;ala-asentoon ja pakki on t‰ysill‰(viel‰ ehk‰ n. 10:t‰ pienempi kuin havaittu lukema).
                                  
  symbol keskiAsema = 1180      ; Lukema, mik‰ vastaa haluttua pys‰ytys/keski-asemaa
  
  
  symbol taysiKaasu = 1550          ; Lukema, mik‰ vastaa haluttua t‰ytt‰ kaasua eteenp‰in
  
  symbol taysiPakki = 850         ; Lukema, mik‰ vastaa haluttua t‰ytt‰ kaasua pakilla
  
  
  symbol akunJanniteMin = 325      ; Kokeile t‰h‰n arvo joka vastaa n.4,5 V akun p‰‰ss‰.
  
  
  symbol maxVirta = 5  ; Kokeilemalla haettu t‰h‰n arvo joka vastaa n. 20 A virtaa. 
  
  symbol virtaLukemaSummaRaja = w10 
  
  virtaLukemaSummaRaja = maxVirta*20
  
  
  symbol akunJanniteLukema = w7
  
  symbol virtaLukemaSumma = w9
  
  symbol virtaLukema = w8
  
  symbol RCvirheLukemat = b27    ; Per‰kkaisten RC-vastarilta tulevien ep‰ilytt‰vien lukemien lukum‰‰r‰.
                                 ; K‰ytet‰‰n siihen ett‰ ei heti turhaan pys‰ytet‰ jos yksitt‰inen
  RCvirheLukemat = 0             ; virhelukema sattuu tulemaan vaan odotetaan esim. kymmenen per‰kk‰ist‰  
                                 ; virhelukemaa ennen kuin reagoidaan t‰h‰n.
  
  
   w1 = keskiAsema - 45
   
   w2 = keskiasema + 50
   
   w3 = keskiasema - 50
   
  
  ; Virta-arvojen keskiarvolukeman alustus:
  
  gosub alustaVirtaArvot 
  
  
main:

   
   pulsin rcVastari, 1, w0


   readadc10 virtalukemaPin, virtaLukema

   
   readadc10 akunJannitePin, akunJanniteLukema ; Testaa tuleeko j‰nnitepinniin h‰iriˆit‰ eli tarvitaanko t‰h‰nkin
                                               ; "keskiarvoajattelua" kuten virran mittaukseen.
   
   ; K‰yd‰‰n laskemassa virtaLukema-muuttujaan virtalukemien "keskiarvo"
   
   gosub laskeVirtaArvo
   
   
    ; tsekataan ramin sis‰ltˆ‰:
   
  ; for b25 = 100 to 119
   
  ;    peek b25, b24  
   
   ;   sertxd(#b24,13,10)
   
  ; next b25
   
  ; sertxd(" ",13,10)
    
   
   
  ; sertxd(#w0,13,10)
   
  ; sertxd(#piikkiVirtaLukema,13,10)
  ; sertxd("Virtalukema:", #virtaLukema,13,10)
  
  ;sertxd("Akun j‰nnitelukema:", #akunJanniteLukema,13,10)

     
   
   ; Jos virtalukemaSumma menee yli maksimirajan menn‰‰n ylikuormits-labeliin.
   
   if virtaLukemaSumma > virtaLukemaSummaRaja then ylikuormitus
   
   
   
  
   ; Jos akun j‰nnite on alhainen menn‰‰n akkuVahissa labeliin.
   ; Testaa t‰h‰n sopiva arvo. Ehk‰ joku 4,5 - 5 V sopiva?
   
   
   if akunJanniteLukema < akunJanniteMin then akkuVahissa


  
  
   
 
   ; Jos tulee kymmenen odottamatonta lukemaa per‰kk‰in niin pys‰ytet‰‰n.
   ; (Siis kymmenennen lukeman tullessa pys‰ytet‰‰n)
   
   if w0 < minLukema  or w0 > maxLukema then          
                              
      
      if RCvirheLukemat < 9 then 
                             
                             
         inc RCvirheLukemat             
         
         goto main
      
      endif

      RCvirheLukemat = 0  ; Tuli tayteen kymmenes per‰kk‰inen virhelukema. Nollataan RCvirheLukemat-muuttuja
                          ; ja laitetaan pakki pois p‰‰lt‰ ja kaasu kiinni. Sitten hyp‰t‰‰n alkuun.
      low pakki

      pwmduty kaasu, 0 

      sertxd(#w0,13,10)

      goto main

   endif
   
   
   RCvirheLukemat = 0
   
   
   
   ;T‰h‰n kohti tultaessa on siis varmasti minLukema <= w0 <= maxLukema
   
   
   if w0 < taysiPakki then      
   
   
       w0 = taysiPakki                     
   
    
   endif
 
 
   if w0 > taysiKaasu then      
   
   
       w0 = taysiKaasu                     
  
    
   endif
   
   
   ;Nyt ollaan siis varmasti v‰lill‰ taysiPakki <= w0 <= taysiKaasu.
   
  
   
   
   if w0 >= w1 and w0 <= w2 then    ; Ollaan siis alueella jossa halutaan varmasti olla paikallaan
 
     ' w0 = 0     ;merkkin‰ paikallaanolosta
 
      low pakki
    
      pwmduty kaasu, 0
 
      sertxd("Duty cycle: ","0",13,10)
      
      
      
      goto main
 
   endif
   
   
   
   if w0 >= w3 and w0 < w1 then ; siirtym‰alue pakin ja paikallaanolon v‰lill‰, ollaan paikallaan
 
     '
                                ; ei muuteta releiden asemaa, jottei tule turhaa napsumista.
      pwmduty kaasu, 0  
 
      sertxd("Duty cycle: ","0",13,10)
 
      goto main
    
   endif
   
   
   
   
   
   if w0 > w2 then
 
 
     w0 = w0 - w2 ; w0 on nyt v‰lill‰ 1,...,taysiKaasu - w2 nyt menn‰‰n eteen p‰in
 
    ; T‰m‰ pit‰‰ nyt osata skaalata v‰lille 1,...,400
    ; Pit‰‰ siis kertoa luvulla 400/w5(w5 m‰‰ritelty alla)
    ; Koska tiedet‰‰n ett‰ kaikki luvut ovat nyt jaollisia kymmenell‰, niin jako w5/10 menee tasan ja voidaan
    ; siis ensin kertoa 40:lla ja sitten jakaa w5/10:lla. N‰in s‰‰styt‰‰n ylivuodolta kertolaskussa.
    ; (Havaittiin, ett‰ suoraan 400:lla kerrottaessa tulisi ylivuoto.)
    
     w5 = taysiKaasu - w2
 
     w5 = w5/10
 
     w0 = w0 * 40
    
     w0 = w0/w5
    
    
    
     low pakki
    
     pwmduty kaasu, w0
    
     ; Lasketaan w5:een duty cycle prosentteina ja tulostetaan n‰ytˆlle.
    
     w5 = w0/4
    
     sertxd("Duty cycle: ",#w5,13,10)
    
     goto main
 
   endif
   
   
  if w0 < w3 then
 
 
 
    w0 = w3 - w0; w0 on nyt v‰lill‰ 1,...,w3-taysiPakki. nyt menn‰‰n taaksep‰in
 
    
 
    ; T‰m‰ pit‰‰ nyt osata skaalata v‰lille 1,...,400
    ; Pit‰‰ siis kertoa luvulla 400/w6(Kun  m‰‰ritell‰‰n w6 = w3-taysiPakki)
    ; Koska tiedet‰‰n ett‰ kaikki luvut ovat nyt kymmenell‰ jaollisia, niin jako w6/10 menee tasan ja voidaan
    ; siis ensin kertoa 40:lla ja sitten jakaa w6/10:lla. N‰in s‰‰styt‰‰n ylivuodolta kertolaskussa.
    
    
    w6 = w3 - taysiPakki
 
    w6 = w6/10
 
    w0 = w0 * 40
    
    w0 = w0/w6
    
    
    
    high pakki
    
    pwmduty kaasu, w0
    
    ; Lasketaan w6:een duty cycle prosentteina ja tulostetaan n‰ytˆlle.
    
    w6 = w0/4
    
    sertxd("Duty cycle: ",#w6,13,10)
    
    goto main
 
   endif
   
   
   
  
  
akkuVahissa:


   pwmduty kaasu, 0
   
   low pakki


   sertxd("Akku v‰hiss‰!",13,10)

   ; Loopataan niin kauan ett‰ akun j‰nnite on palautunut ja kaasu on 
   ; lˆys‰tty keskiaseman l‰heisyyteen.
   
   do
   
     
      high ledi 
   
      pause 12000
   
      low ledi
   
      pause 12000
   
      readadc10 akunJannitePin, akunJanniteLukema
      
      pulsin rcVastari, 1, w0
   
   loop while akunJanniteLukema < akunJanniteMin or w0 < w3 or w0 > w2
   
   
   goto main
   
   
   
ylikuormitus:


   pwmduty kaasu, 0
   
   low pakki

   sertxd("Ylikuormitus!",13,10)


   ; Vilkutetaan viisi kertaa ledi‰ jonka j‰lkeen odotetaan
   ; ett‰ kaasu lˆys‰t‰‰n ennen kuin menn‰‰n main-leibeliin takaisin. 
   
   
   for b26 = 0 to 4
   
      high ledi
      
      pause 4000
      
      low ledi
      
      pause 4000
    
   next b26   
   
   
   do
   
      pulsin rcVastari, 1, w0
   
   loop while w0 < w3 or w0 > w2
   
   gosub alustaVirtaArvot
   
   goto main 
   
   
      
   
laskeVirtaArvo:

   ;Voidaan olettaa ett‰ virtalukemat ovat niin pieni‰ ett‰ ne mahtuvat yhteen tavuun(max 255)

   @bptrinc = virtaLukema

   if bptr = 120 then
   
      bptr = 100
   
   endif
   
   virtaLukemaSumma = 0
   
   for b25 = 100 to 119
   
      peek b25, b24  
   
      virtaLukemaSumma = virtaLukemaSumma + b24
   
   next b25
   

   return 
   
   
   
alustaVirtaArvot:

   bptr = 100
   
   do
   
      @bptrinc = 0

   loop until bptr = 120

   bptr = 100 ; pointteri alustuksen j‰lkeen ensimm‰iseen arvoon.

   return   