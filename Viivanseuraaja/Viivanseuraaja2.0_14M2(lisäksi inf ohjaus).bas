; Ohjelman nimi: Viivanseuraaja2_14M2(lisäksi inf ohjaus).bas

; Tekijä: Olli Pulkkinen

; Tehty: 23.12.2012


; Tässä ohjelmassa on mahdollisuus vaihtaa viivanseurannan ohjelma manuaaliseen infrapuna-
; ohjaukseen ja takaisin. Viivanseurannan ohjelma on alkuperäinen yksinkertainen ohjelma,
; jolla seuraaja eksyy viivalta esim. liian jyrkissä mutkissa. Alkuperäiseen ohjelmakoodiin
; on tehty vain hieman lisäyksiä ja muutoksia, mutta alkuperäisen ohjelman rakenne on edelleen 
; tunnistettavissa automaatti-osiosta. Käytettävät jalat ovat muuten samat, paitsi että lisäksi 
; otetaan infrapunaohjaus vastaan C.4:sta. Vastaavaa ohjelmaa voitaisiin käyttää myös 08M2:lla,
; koska pin 2 on alkuperäisessä viivanseuraajan ohjelmassa käyttämättä ja sitä voidaan käyttää 
; tarvittaessa infrapunan vastaanottoon.




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
       
      if aikaVali >=2 then  
        
         aika = time 
          
         goto manuaalinen
         
      endif   
   
   endif    
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta
   
                                                         
   high oikeaM, vasenM
   
   pause 10
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta

 
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

   low B.1, B.4

   goto manuaalinen 