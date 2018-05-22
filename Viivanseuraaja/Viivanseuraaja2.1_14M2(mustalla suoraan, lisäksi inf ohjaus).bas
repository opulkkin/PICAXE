; Ohjelman nimi: Viivanseuraaja2.1_14M2(mustalla suoraan, lisäksi inf ohjaus).bas

; Tekijä: Olli Pulkkinen

; Tehty: 27.12.2012


; Tässä ohjelmassa on mahdollisuus vaihtaa viivanseurannan ohjelma manuaaliseen infrapuna-
; ohjaukseen ja takaisin. Viivanseuraaja1.1_14M2(mustalla suoraan).bas- ohjelman koodista
; on otettu viivanseurannan ohjelma, jolloin siis seuraaja eksyy viivalta esim. liian jyrkissä 
; mutkissa. Seuraaja voidaan kuitenkin ajaa infrapunalla takaisin viivalle. 

; Käytettävät jalat ovat muuten samat, paitsi että lisäksi 
; otetaan infrapunaohjaus vastaan C.4:sta. Vastaavaa ohjelmaa voitaisiin käyttää myös 08M2:lla,
; koska pin 2 on alkuperäisessä viivanseuraajan ohjelmassa käyttämättä ja sitä voidaan käyttää 
; tarvittaessa infrapunan vastaanottoon. 08M2:een vaihdettaessa riittää siis muuttaa taas vain
; oikeat pinnit symbol-määrityksiin.



   symbol oikeaA = pinC.1        ; oikea anturi

   symbol vasenA = pinC.3        ; vasen anturi

   symbol oikeaM = B.4           ; oikea moottori

   symbol vasenM = B.1           ; vasen moottori
   
   symbol infVastOt = C.4        ;infrapunasignaalin vastaanotto C.4:sta
   
   
   
   
   symbol viesti = b0

   symbol aika = w1
   
   symbol aikaVali = w2
    
   
   viesti = 0
   
   aika = 0
   
; Itse ohjelmakoodi

automaatti:

   
   low oikeaM, vasenM
   
   irin [8], infVastOt, viesti
   
   if viesti = 7 then
      
      viesti = 0
      
      aikaVali = time - aika
       
      if aikaVali >=2 then      ; Tämä if- testaus on siksi ettei vahingossa pompita
        				  ; nopeasti automaatin ja manuaaliohjauksen välillä.
         aika = time 
          
         goto manuaalinen
         
      endif   
   
   endif    
   
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia   ; Tässä alkaa olemaan jo sen verran monta peräkkäistä if-lauseketta
   								     ; että kannattaisi miettiä jotain vaihtoehtoista rakennetta, esim.
   if vasenA = 0 then kaytaOikeaa			     ; select-case rakennetta. Yleensä suuri määrä if/else -käskyjä kan-
                                                     ; nattaa korvata jollakin toisella rakenteella, jolloin melko varmasti 
   if oikeaA = 0 then 			                 ; koodi lyhentyy, on selkeämpää ja jopa toimii nopeammin.
   
       goto kaytaVasenta
   
   else
   
       goto kaytaMolempia       ; Nyt vaalealla ajettaessa mennään hieman hiljempaa kuin tummalla ajettaessa,
   					  ; koska pausen pituudesta low oikeaM, vasenM käskyn jälkeen tulee hieman pidempi
   endif                        ; if-testausten myötä, mutta vaikutus on käytännössä täysin marginaalinen.
 
   goto automaatti
   
   
kaytaMolempia:
   
   high oikeaM, vasenM
   
   pause 10
   
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
   
   irin [100, pysaytys], infVastOt, viesti  
   
   
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
      
      aikaVali = time - aika
       
      if aikaVali >=2 then  
        
         aika = time 
          
         goto automaatti
         
      endif   
   
      
                                                            
   endselect                   
    	                               
   goto manuaalinen
                        		  
pysaytys:

   low vasenM, oikeaM

   goto manuaalinen 