; Ohjelman nimi: Viivanseuraaja2.2_14M2(yleisInfraOhjaus).bas

; Tekij‰: Olli Pulkkinen

; Tehty: 12.2.2013



; Viivanseuraajan ohjelman lis‰ksi mukana on IR-ohjausmahdollisuus. Ohjauksen pit‰isi toimia mill‰ tahansa IR-s‰‰timell‰.
; Ohjaamiseen voi k‰ytt‰‰ mit‰ tahansa s‰‰timen nappia. Aluksi on k‰ytˆss‰ viivanseurantaohjelma, ja manuaaliohjaukseen
; p‰‰st‰‰n painamalla kerran jotain ohjaimen nappia. T‰llˆin viivanseuraaja pys‰htyy ja manuaaliohjaus menee p‰‰lle.

; Manuaaliohjaus toimii seuraavasti: Yhdell‰ nopealla painalluksella aletaan pyˆri‰ vasemmalle ja 
; nopealla kaksoispainalluksella aletaan pyˆri‰ oikealle. Suoraan p‰‰st‰‰n pit‰m‰ll‰ nappia pohjassa jonkin aikaa. 
; Viivanseuraaja voidaan pys‰ytt‰‰ samoilla komennoilla kuin p‰‰stiin liikkeellekin. Jos menn‰‰n
; suoraan, saa seuraajan pys‰ytetty‰ pit‰m‰ll‰ ohjaimen nappia pohjassa riitt‰v‰n pitk‰‰n. Vasemmalle pyˆritt‰ess‰ voi-
; daan pys‰hty‰ painamalla nappia kerran nopeasti, oikealle pyˆritt‰ess‰ pys‰htyminen onnistuu puolestaan nopealla
; tuplapainalluksella. 

; Viivanseurannan ohjelmaan p‰‰st‰‰n takaisin, kun manuaaliohjauksessa pys‰ytet‰‰n viivanseuraaja,
; ododotetaan hetki (1-2s) ja t‰m‰n j‰lkeen pidet‰‰n ohjausnappia pohjassa jonkun aikaa. T‰llˆin automaatti k‰ynnistyy. 


   symbol oikeaA = pinC.1        ; Oikea anturi. 08M2:n tapauksessa laita t‰h‰n pinC.1:n paikalle pin1,
                                 ; tosin pinC.1 taitaa sellaisenaankin toimia, koska 08M2:n kaikki pinnit
					   ; kuuluvat ainakin manuaalin mukaan C-porttiin.
  
   symbol vasenA = pinC.3        ; Vasen anturi. 08M2:n tapauksessa laita t‰h‰n pinC.3:n paikalle pin3,
                                 ; tosin pinC.3 taitaa sellaisenaankin toimia.

   symbol oikeaM = B.4           ; Oikea moottori. 08M2:n tapauksessa laita t‰h‰n B.4:n paikalle 4.

   symbol vasenM = B.1           ; Vasen moottori. 08M2:n tapauksessa laita t‰h‰n B.1:n paikalle 0.
   
   symbol infVast = pinC.0       ; Infrapunavastaanotin
   
   symbol valinta = b3
    
   valinta = "a"                 ; a = automaatti, m = manuaalinen.

   symbol suunta = b1

   suunta = 0

   symbol laskuri = b2

   symbol vaihtoAika = w2
   

; Itse ohjelmakoodi




automaatti:

   
   low oikeaM, vasenM
   
   if time = 0 then
   
      setint %00000000, %00000001, C   't‰m‰ interrupt tulee nyt turhaan asetettua useaan
   						   'kertaan sekunnin aikana, mutta ei haittaa...
   endif
   
   if valinta = "m" then
       
      pause 500 
       
      goto manuaalinen
   
   endif 
   
   pause 8
   
  
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   
   goto kaytaMolempia                      ; Ajetaan suoraan sek‰ mustalla alueella ett‰
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
       
             if b0 = 1 then      ' T‰t‰ if lauseketta ei v‰ltt‰m‰tt‰ tarvita, ei haittaa mit‰‰n vaikka sijoitus
                                 ' b0 = 2 teht‰isiin useamminkin kuin kerran.
                 b0 = 2
                 
             endif
       
          endif
     
       next laskuri
           
       
       if b0 = 2 then   
          
          for laskuri = 1 to 50         ' T‰ss‰ voisi olla myˆs joku muu arvo kuin 50, k‰y‰nnˆss‰ koskaan
                                        ' silmukkaa ei suoriteta 50 kertaa, vaan poistutaan if-rakenteesta
             if pinC.0 = 0 then         ' aiemmin exitill‰.
       
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
            
            if suunta = 0 then                ; korvaa sis‰kk‰iset iffit select suunta lauseilla!
            
               vaihtoAika = time - vaihtoAika
            
               if vaihtoAika >= 2 then        ; Jos on odotettu pitk‰‰n paikallaan niin 
                                              ; k‰ynnistyykin automaatti.     
                  valinta = "a"             
              
                  time = 65534        ; 0 tulee siis taas 1-2s p‰‰st‰ t‰st‰ k‰skyst‰
                  
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
   
   
interrupt:


   low oikeaM, vasenM
   
   vaihtoAika = time             
                                
   valinta = "m"
    
   return
   