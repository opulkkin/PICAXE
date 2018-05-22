; Ohjelman nimi: Viivanseuraaja2.3_14M2(yleisInfraOhjaus2 ja SonyOhjaus lisäksi).bas

; Tekijä: Olli Pulkkinen

; Tehty: 2.3.2013



; Yksinkertaisen viivanseuraajan ohjelman lisäksi mukana on kaksi eri infrapunaohjausohjelmaa. Sony-standardin mukaiseen ajo-ohjelmaan
; pääsee painamalla kahdesti puolen sekunnin aikana 8-näppäintä Sonyn tv-kaukosäätimessä, ja millä tahansa infrapuna-
; säätimellä toimivaan ohjelmaan painamalla kerran jotain näppäintä(paitsi ei sony-säätimen 8-näppäintä).
; Sony-ohjaus toimii kaukosäätimen napeilla 2 (eteen), 4(vasemmalle), 6(oikealle) ja 8(vaihto takaisin automaatille).

; Millä tahansa infrapunasäätimellä toimiva ohjaus on seuraava: Yhdellä nopealla painalluksella aletaan pyöriä vasemmalle ja 
; nopealla kaksoispainalluksella aletaan pyöriä oikealle. Suoraan päästään pitämällä nappia pohjassa jonkin aikaa. 
; Viivanseuraaja voidaan pysäyttää samoilla komennoilla kuin päästiin liikkeellekin. Jos mennään
; suoraan, saa seuraajan pysäytettyä pitämällä ohjaimen nappia pohjassa riittävän pitkään. Vasemmalle pyörittäessä voi-
; daan pysähtyä painamalla nappia kerran nopeasti, oikealle pyörittäessä pysähtyminen onnistuu puolestaan nopealla
; tuplapainalluksella. Viivanseurannan ohjelmaan päästään takaisin, kun manuaaliohjauksessa pysäytetään viivanseuraaja,
; ododotetaan hetki (1-2s) ja tämän jälkeen pidetään ohjausnappia pohjassa jonkun aikaa. Tällöin automaatti käynnistyy. 


   symbol oikeaA = pinC.1        ; Oikea anturi. 08M2:n tapauksessa laita tähän pinC.1:n paikalle pin1,
                                 ; tosin pinC.1 taitaa sellaisenaankin toimia, koska 08M2:n kaikki pinnit
					   ; kuuluvat ainakin manuaalin mukaan C-porttiin.
  
   symbol vasenA = pinC.3        ; Vasen anturi. 08M2:n tapauksessa laita tähän pinC.3:n paikalle pin3,
                                 ; tosin pinC.3 taitaa sellaisenaankin toimia.

   symbol oikeaM = B.4           ; Oikea moottori. 08M2:n tapauksessa laita tähän B.4:n paikalle 4.

   symbol vasenM = B.1           ; Vasen moottori. 08M2:n tapauksessa laita tähän B.1:n paikalle 0.
   
   symbol infVast = C.0          ; Infrapunavastaanotin
   
   symbol valinta = b3
    
   valinta = "a"                 ; a = automaatti, m = manuaalinen.

   symbol suunta = b1

   suunta = 0

   symbol laskuri = b2

   symbol vaihtoAika = w2
   
   symbol viesti = b6

   symbol aika = w4
   
   
; Itse ohjelmakoodi




automaatti:

   
   low oikeaM, vasenM
   
   if time = 0 then
   
      setint %00000000, %00000001, C   'tämä interrupt tulee nyt turhaan asetettua useaan
   						   'kertaan sekunnin aikana, mutta ei haittaa...
   endif                               'olisi helppo myös muuttaa siten että asetetaan vain kerran
                                       'tällöin ei tarvittaisi ao. setint off- komentoa
   if valinta = "m" then
       
      viesti = 0
   
      setint off                  ' varmistetaan että interrupt ei ole asetettuna enää...
   
      irin [500], infVast, viesti
      
      if viesti = 7 then manuaalinen2
      
      goto manuaalinen
   
   endif 
   
   pause 8
   
  
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   
   goto kaytaMolempia                      ; Ajetaan suoraan sekä mustalla alueella että
 							 ; vaalealla alueella.
   
   
   
kaytaMolempia:
   
   high oikeaM, vasenM
   
   pause 8
   
   goto automaatti
   
kaytaOikeaa:
   
   low oikeaM, vasenM
    
   high oikeaM
   
   pause 20
   
   goto automaatti
   

kaytaVasenta:
   
   low oikeaM, vasenM
   
   high vasenM
   
   pause 20
   
   goto automaatti
   


manuaalinen:    

   b0 = 0

   if pinC.0 = 0 then       
         
       b0 = 1

       pause 130
       
       for laskuri = 1 to 50 
       
          if pinC.0 = 0 then
       
             if b0 = 1 then      ' Tätä if lauseketta ei välttämättä tarvita, ei haittaa mitään vaikka sijoitus
                                 ' b0 = 2 tehtäisiin useamminkin kuin kerran.
                 b0 = 2
                 
             endif
       
          endif
     
       next laskuri
           
       
       if b0 = 2 then   
          
          for laskuri = 1 to 50         ' Tässä voisi olla myös joku muu arvo kuin 50, käyännössä koskaan
                                        ' silmukkaa ei suoriteta 50 kertaa, vaan poistutaan if-rakenteesta
             if pinC.0 = 0 then         ' aiemmin exitillä.
       
                b0 = 3
          
                exit
          
             endif
          
          next laskuri
       
       endif   
             
   endif
   
  
   select b0
   
   
      case 1
      
         
         if suunta = 1 then 
         
            low oikeaM, vasenM
            
            suunta = 0
            
            vaihtoAika = time
         
         else
            
            low vasenM
      
            high oikeaM
            
            suunta = 1
         
         endif
         
         pause 200
         
      case 2
       
         if suunta = 2 then 
         
            low vasenM, oikeaM
            
            suunta = 0
            
            vaihtoAika = time
         
         else
            
            low oikeaM
         
            high vasenM
            
            suunta = 2
         
         endif
         
         pause 200
      
      case 3
         
        
         if suunta = 3 then 
         
            low oikeaM, vasenM
            
            suunta = 0
            
            vaihtoAika = time
         
         else
            
            if suunta = 0 then                ; korvaa sisäkkäiset iffit select suunta lauseilla!
            
               vaihtoAika = time - vaihtoAika
            
               if vaihtoAika >= 2 then        ; Jos on odotettu pitkään paikallaan niin 
                                              ; käynnistyykin automaatti.     
                  valinta = "a"             
              
                  time = 65534        ; 0 tulee siis taas 1-2s päästä tästä käskystä
                  
                  goto automaatti
       
               else
               
                   high oikeaM, vasenM            
               
                   suunta = 3 
               
               endif
                       				   
            else
            
               high oikeaM, vasenM            
               
               suunta = 3 
             
            endif    
         
         endif
            				   
         pause 500
   
   endselect
   
   goto manuaalinen
   

manuaalinen2:
  
   
   irin [100, pysaytys], infVast , viesti  
   
   
   select case viesti
   
   case 1
      
      high vasenM, oikeaM
   
   
   case 3
   
      low vasenM
      
      high oikeaM
      
   
   case 5
   
      low oikeaM
      
      high vasenM
   
   case 7
      
      low vasenM, oikeaM
      
      viesti = 0
      
      aika = time - vaihtoAika   
       					   
      if aika >= 2 then  
        
         valinta = "a"             
              
         time = 65534
          
         goto automaatti
         
      endif   
        
                                                            
   endselect                   
    	                               
   goto manuaalinen2
                        		  
pysaytys:

   low vasenM, oikeaM

   goto manuaalinen2



   
interrupt:


   low oikeaM, vasenM
   
   vaihtoAika = time             
   
   valinta = "m"
    
   return
   