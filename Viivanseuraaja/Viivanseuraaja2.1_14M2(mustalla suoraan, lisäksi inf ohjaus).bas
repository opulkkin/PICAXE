; Ohjelman nimi: Viivanseuraaja2.1_14M2(mustalla suoraan, lis�ksi inf ohjaus).bas

; Tekij�: Olli Pulkkinen

; Tehty: 27.12.2012


; T�ss� ohjelmassa on mahdollisuus vaihtaa viivanseurannan ohjelma manuaaliseen infrapuna-
; ohjaukseen ja takaisin. Viivanseuraaja1.1_14M2(mustalla suoraan).bas- ohjelman koodista
; on otettu viivanseurannan ohjelma, jolloin siis seuraaja eksyy viivalta esim. liian jyrkiss� 
; mutkissa. Seuraaja voidaan kuitenkin ajaa infrapunalla takaisin viivalle. 

; K�ytett�v�t jalat ovat muuten samat, paitsi ett� lis�ksi 
; otetaan infrapunaohjaus vastaan C.4:sta. Vastaavaa ohjelmaa voitaisiin k�ytt�� my�s 08M2:lla,
; koska pin 2 on alkuper�isess� viivanseuraajan ohjelmassa k�ytt�m�tt� ja sit� voidaan k�ytt�� 
; tarvittaessa infrapunan vastaanottoon. 08M2:een vaihdettaessa riitt�� siis muuttaa taas vain
; oikeat pinnit symbol-m��rityksiin.



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
       
      if aikaVali >=2 then      ; T�m� if- testaus on siksi ettei vahingossa pompita
        				  ; nopeasti automaatin ja manuaaliohjauksen v�lill�.
         aika = time 
          
         goto manuaalinen
         
      endif   
   
   endif    
   
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia   ; T�ss� alkaa olemaan jo sen verran monta per�kk�ist� if-lauseketta
   								     ; ett� kannattaisi mietti� jotain vaihtoehtoista rakennetta, esim.
   if vasenA = 0 then kaytaOikeaa			     ; select-case rakennetta. Yleens� suuri m��r� if/else -k�skyj� kan-
                                                     ; nattaa korvata jollakin toisella rakenteella, jolloin melko varmasti 
   if oikeaA = 0 then 			                 ; koodi lyhentyy, on selke�mp�� ja jopa toimii nopeammin.
   
       goto kaytaVasenta
   
   else
   
       goto kaytaMolempia       ; Nyt vaalealla ajettaessa menn��n hieman hiljempaa kuin tummalla ajettaessa,
   					  ; koska pausen pituudesta low oikeaM, vasenM k�skyn j�lkeen tulee hieman pidempi
   endif                        ; if-testausten my�t�, mutta vaikutus on k�yt�nn�ss� t�ysin marginaalinen.
 
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