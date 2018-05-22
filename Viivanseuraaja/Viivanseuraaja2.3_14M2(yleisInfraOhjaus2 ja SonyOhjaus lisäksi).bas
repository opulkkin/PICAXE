; Ohjelman nimi: Viivanseuraaja2.3_14M2(yleisInfraOhjaus2 ja SonyOhjaus lis�ksi).bas

; Tekij�: Olli Pulkkinen

; Tehty: 2.3.2013



; Yksinkertaisen viivanseuraajan ohjelman lis�ksi mukana on kaksi eri infrapunaohjausohjelmaa. Sony-standardin mukaiseen ajo-ohjelmaan
; p��see painamalla kahdesti puolen sekunnin aikana 8-n�pp�int� Sonyn tv-kaukos��timess�, ja mill� tahansa infrapuna-
; s��timell� toimivaan ohjelmaan painamalla kerran jotain n�pp�int�(paitsi ei sony-s��timen 8-n�pp�int�).
; Sony-ohjaus toimii kaukos��timen napeilla 2 (eteen), 4(vasemmalle), 6(oikealle) ja 8(vaihto takaisin automaatille).

; Mill� tahansa infrapunas��timell� toimiva ohjaus on seuraava: Yhdell� nopealla painalluksella aletaan py�ri� vasemmalle ja 
; nopealla kaksoispainalluksella aletaan py�ri� oikealle. Suoraan p��st��n pit�m�ll� nappia pohjassa jonkin aikaa. 
; Viivanseuraaja voidaan pys�ytt�� samoilla komennoilla kuin p��stiin liikkeellekin. Jos menn��n
; suoraan, saa seuraajan pys�ytetty� pit�m�ll� ohjaimen nappia pohjassa riitt�v�n pitk��n. Vasemmalle py�ritt�ess� voi-
; daan pys�hty� painamalla nappia kerran nopeasti, oikealle py�ritt�ess� pys�htyminen onnistuu puolestaan nopealla
; tuplapainalluksella. Viivanseurannan ohjelmaan p��st��n takaisin, kun manuaaliohjauksessa pys�ytet��n viivanseuraaja,
; ododotetaan hetki (1-2s) ja t�m�n j�lkeen pidet��n ohjausnappia pohjassa jonkun aikaa. T�ll�in automaatti k�ynnistyy. 


   symbol oikeaA = pinC.1        ; Oikea anturi. 08M2:n tapauksessa laita t�h�n pinC.1:n paikalle pin1,
                                 ; tosin pinC.1 taitaa sellaisenaankin toimia, koska 08M2:n kaikki pinnit
					   ; kuuluvat ainakin manuaalin mukaan C-porttiin.
  
   symbol vasenA = pinC.3        ; Vasen anturi. 08M2:n tapauksessa laita t�h�n pinC.3:n paikalle pin3,
                                 ; tosin pinC.3 taitaa sellaisenaankin toimia.

   symbol oikeaM = B.4           ; Oikea moottori. 08M2:n tapauksessa laita t�h�n B.4:n paikalle 4.

   symbol vasenM = B.1           ; Vasen moottori. 08M2:n tapauksessa laita t�h�n B.1:n paikalle 0.
   
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
   
      setint %00000000, %00000001, C   't�m� interrupt tulee nyt turhaan asetettua useaan
   						   'kertaan sekunnin aikana, mutta ei haittaa...
   endif                               'olisi helppo my�s muuttaa siten ett� asetetaan vain kerran
                                       't�ll�in ei tarvittaisi ao. setint off- komentoa
   if valinta = "m" then
       
      viesti = 0
   
      setint off                  ' varmistetaan ett� interrupt ei ole asetettuna en��...
   
      irin [500], infVast, viesti
      
      if viesti = 7 then manuaalinen2
      
      goto manuaalinen
   
   endif 
   
   pause 8
   
  
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   
   goto kaytaMolempia                      ; Ajetaan suoraan sek� mustalla alueella ett�
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
       
             if b0 = 1 then      ' T�t� if lauseketta ei v�ltt�m�tt� tarvita, ei haittaa mit��n vaikka sijoitus
                                 ' b0 = 2 teht�isiin useamminkin kuin kerran.
                 b0 = 2
                 
             endif
       
          endif
     
       next laskuri
           
       
       if b0 = 2 then   
          
          for laskuri = 1 to 50         ' T�ss� voisi olla my�s joku muu arvo kuin 50, k�y�nn�ss� koskaan
                                        ' silmukkaa ei suoriteta 50 kertaa, vaan poistutaan if-rakenteesta
             if pinC.0 = 0 then         ' aiemmin exitill�.
       
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
            
            if suunta = 0 then                ; korvaa sis�kk�iset iffit select suunta lauseilla!
            
               vaihtoAika = time - vaihtoAika
            
               if vaihtoAika >= 2 then        ; Jos on odotettu pitk��n paikallaan niin 
                                              ; k�ynnistyykin automaatti.     
                  valinta = "a"             
              
                  time = 65534        ; 0 tulee siis taas 1-2s p��st� t�st� k�skyst�
                  
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
   