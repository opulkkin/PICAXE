; Ohjelman nimi: Viivanseuraaja4.1_14M2.bas

; Tekij�: Olli Pulkkinen

; Tehty: 28.12.2012


; T�m� ohjelma on l�hes sama kuin versio 3.1 muuten. mutta nyt nyt mukaan on lis�tty infrapunaohjauksen mahdollisuus.
; Alussa on p��ll� automaattinen viivanseuranta, joka toimii l�hes samoin kuin ohjelmaversiossa 3.1. Nyt kuitenkin
; alussa ajetaan suoraan kunnes viiva l�ytyy tai viivan etsint��n k�ytett�v� maksimiaika eMaxAika umpeutuu. Jos viiva
; l�ytyy aletaan seurata sit� ja jos ei l�ydy, vaihdetaan etsinn�n maksimiajan kuluttua manuaaliohjaukselle.
; Lis�ksi t�m� ohjelma eroaa versiosta 3.1 s.e jos molemmat anturit ovat mustalla (ajetaan suoraan) niin lis�ksi
; "arvotaan" uusiksi kummalla puolella viiva on n�hty viimeksi.

; Kaukos��timell� voidaan milloin tahansa vaihtaa manuaaliohjaukselle. Kun vaihdetaan manuaaliohjaukselta automaatille,
; niin toimitaan samantyyppisesti kuin ohjelman alussa, eli ajetaan suoraan kunnes viiva l�ytyy tai aikaraja umpeutuu.
; Tarkoitus on siis, ett� sek� alussa ett� kytkett�ess� automaattiohjaus uudelleen haetaan ensin viivaa suoraan edest�.
; T�ll�in siis seuraaja voidaan laittaa hieman kauempaakin menem��n kohti viivaa ja sen pit�isi j��d� viivan ymp�rist��n,
; jos viiva ehdit��n vain saavuttaa ennen aikarajan umpeutumista. 

; Jos viiva jostain syyst� karkaa lopullisesti, niin ei lopeteta ohjelmaa(kuten 3.1-versiossa), vaan pys�ytet��n
; ja vaihdetaan manuaaliohjaukseen.
 

; Yksi  j�rkev� p�ivitys t�h�n versioon(ja my�s muihin) saattaisi olla pwm-ulostulojen k�ytt� moottorien py�rityksess�, 
; jolloin ei tarvisi turhaan tehd� ohjelman suoritusta keskeytt�vi� low/pause-komentoja hitaamman py�rimisen saavuttamiseksi. 
; T�m� ei kuitenkaan taida onnistua 08M2:sta k�ytett�ess�, koska siin� on ainakin manuaalin mukaan vain yksi pwm-tyyppinen
; ulostulo. 14M2:lla luultavasti onnistuisi, mutta infrapunan vastaanoton hoitaminen samalla saattaisi olla hieman
; hankalaa sill�kin.

; Koodia alkaa olemaan jo ihan mukavasti, ja erityisesti viivanEtsint�-osiossa koodia saattaisi saada selke�mm�ksi ja
; lyhemm�ksi esim. aliohjelmien avulla. T�ss� kuitenkin ohjelman ensimm�inen versio, toivottavasti toimii yll� kuvatulla
; tavalla :)


   symbol oikeaA = pinC.1        ; Oikea anturi

   symbol vasenA = pinC.3        ; Vasen anturi

   symbol oikeaM = B.4           ; Oikea moottori

   symbol vasenM = B.1           ; Vasen moottori          

   symbol infVastOt = C.4        ;infrapunasignaalin vastaanotto C.4:sta






   symbol viimHav = b8         ; Tieto siit� kummalla puolella viiva on viimeksi havaittu. Jos viiva havaitaan
				       ; molemmilla puolilla, niin t�t� arvoa ei muuteta edellisest� arvosta.
				       ; K�ytet��n muistamisen helpottamiseksi sis��ntulona k�ytett�vien 
			             ; jalkojen kanssa yhteensopivaa koodausta ja sovitaan, ett�
				       ; 1 = oikea puoli ja 3 = vasen puoli.
				    
   symbol viimHavAika = w0     ; Viimeisimm�n viivahavainnon aika sekunteina ohjelman
				       ; k�ynnistymisest� laskettuna(ainakin 4MHz k�ytett�ess�). 

   symbol aikaVali = w1        ; T�h�n muuttujaan lasketaan ohjelmassa kulunut aika 
				       ; viimeisimm�st� viivahavainnosta.

   symbol maxAika = 2          ; Aika, joka maksimissaan odotetaan viimeisimm�st� viivahavainnosta  
					 ; ennen kuin viivan etsint� k�ynnistet��n. Vaihdettu nyt 2:ksi, jotta
				       ; mustalta alueelta voidaan joskus eksy�. Jos t�ss� on 1, niin ei
                               ; p��st� yleens� karkuun(vaatii jo melko erikoisen radan).
                               
   symbol eAAika = w2          ; eAAika = etsinn�n aloituksen aika. T�m� otetaan yl�s siin� vaiheessa				       
				       ; kun viivaa aletaan etsim��n.

   symbol eKAika = w3          ; eKAika = etsint��n k�ytetty aika. T�h�n tallennetaan tieto siit� kauanko				       
				       ; viivaa on etsitty.

   symbol eMaxAika = 15         ; Viivan etsint��n k�ytett�v� maksimiaika.


   
   
   
   symbol viesti = b9       ; T�h�n tallennetaan aina vastaanotettu infrapunasignaali.

   symbol infAika = w5      ; koostuu b10:sta ja b11:sta jotka eiv�t viel� ole muualla k�yt�ss�.
                            ; K�ytet��n infrapunaohjauksen ja automaattiohjauksen vaihtoon liittyv�ss� tekniikassa.
   
   
   symbol infAikaVali = w6  ; koostuu b12:sta ja b13:sta jotka eiv�t viel� ole muualla k�yt�ss�.
                            ; K�ytet��n infrapunaohjauksen ja automaattiohjauksen vaihtoon liittyv�ss� tekniikassa.



; Alustukset

   low oikeaM, vasenM 

   viimHav = 0                 ; Alustetaan nyt nollaksi toisin kuin ohjelmaversiossa 3.1.
				       
   viimHavAika = 0
 
   viesti = 0
   
   infAika = 0




; Itse ohjelmakoodi

automaatti:

   
   low oikeaM, vasenM
   
   
   irin [5], infVastOt, viesti
   
   if viesti = 7 then
      
      viesti = 0
      
      infAikaVali = time - infAika
       
      if infAikaVali >=2 then      ; T�m� if- testaus on siksi ettei vahingossa pompita
        				     ; nopeasti automaatin ja manuaaliohjauksen v�lill�.
         infAika = time 
          
         goto manuaalinen
         
      endif   
   
   endif 
   
   
   
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia     
 
   
   
   gosub haeAikaVali                                 ; T�nne tullaan t�sm�lleen silloin kun molemmat ovat vaalealla.
   
   if aikaVali >= maxAika then viivanEtsinta         ; T�ss� oleva arvo maxAika m��r�� sen kuinka kauan odotetaan
   					                       ; viivahavainnosta ennen poikkeustoimien k�ynnistymist�
                                                     ; ViivanEtsinta k�ynnistyy jos havainnosta on kulunut 
                                                     ; enenmm�n kuin maxAika.
   
   goto kaytaMolempia
                                                                 
      


kaytaMolempia:             
 
   if vasenA = 0 or oikeaA = 0 then                      ; P�ivitet��n viivan havaintoaika jos v�hint��n toinen
                                                         ; anturi on viivalla. Jos molemmat ovat vaalealla, niin
      viimHavAika = time		                     ; p�ivityst� ei tehd�(k�yt�nn�ss� t�nne tultaessa molemmat ovat vaalealla      					   ;
                                                         ; tai sitten molemmat ovat mustalla, eli voisi olla my�s and or:n tilalla)
      viimHav = time % 2  ; tulos = 0 tai 1	         ; Lis�ksi "arvotaan" viimHav uusiksi toisin kuin versiossa 3.1. T�m� tehd��n	   .
                                                         ; todella yksinkertaisesti ottamalla jakoj��nn�s modulo 2 time-muuttujasta
                                                         ; T�m� ei todellakaan ole kauhean hyv� "satunnaislukugeneraattori", mutta 
      if viimhav = 0 then                                ; aivan riitt�v� t�ss�.
                                                         
         viimHav = 1
      
      else
      
         viimHav = 3
      
      endif
      					   
  
   endif                                
                                       
   high oikeaM, vasenM
   
   pause 10

   goto automaatti

   
   
kaytaOikeaa:
   
   viimHavAika = time
   
   viimHav = 3            ; Viiva havaittu vasemmalla anturilla kun t�nne on tultu
   
   high oikeaM
   
   pause 20
   
   goto automaatti
   

kaytaVasenta:
   
   viimHavAika = time
   
   viimHav = 1           ; Viiva havaittu oikealla anturilla kun t�nne on tultu
   
   high vasenM
   
   pause 20
   
   goto automaatti

   

haeAikaVali:                          ; T�m� aliohjelma laskee aikaVali- muuttujaan sen ajan (sekuntien tarkkuudella)
                                      ; kuinka kauan on kulunut viimeisimm�st� viivahavainnosta. T�m�n j�lkeen palataan
   aikaVali = time - viimHavAika      ; koodissa gosub- k�skyn j�lkeiselle riville ja jatketaan suoritusta siit�.
						  ; Ei v�ltt�m�tt� kannattaisi tehd� n�in lyhyit� aliohjelmia, mutta olkoon.
   return
   
   
viivanEtsinta:

  
   eAAika = time
   
   
   select case viimHav    
   
    
    case 1                ; Viiva havaittu viimeksi oikealla
      
      do until vasenA = 0 ; Py�rit��n (hitaasti) my�t�p�iv��n niin kauan ett� vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaVasenta2
         
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
            viesti = 0
      
            infAikaVali = time - infAika
       
            if infAikaVali >=2 then      
        				           
               infAika = time 
          
               goto manuaalinen
         
            endif   
   
         endif
   
         
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei j��d� py�rim��n kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
            
      
      loop 
       
    
    case 3                   ; Viiva havaittu viimeksi vasemmalla
   
      
      do until oikeaA = 0 ; Py�rit��n (hitaasti) vastap�iv��n niin kauan ett� vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaOikeaa2
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
             viesti = 0
      
             infAikaVali = time - infAika
       
             if infAikaVali >=2 then      
        				     
                 infAika = time 
          
                 goto manuaalinen
         
             endif   
   
         endif
         
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei j��d� py�rim��n kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
      
         
      loop 
       
    case 0                                 ; Viivasta ei havaintoa, ts. havainto nollattu.
   
      do until vasenA = 0 or oikeaA = 0    ; Ajetaan (hitaasti) suoraan niin kauan ett� viiva l�ytyy 
   				                   ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaMolempia2
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
            viesti = 0
      
            infAikaVali = time - infAika
       
            if infAikaVali >=2 then      
        				           
               infAika = time 
          
               goto manuaalinen
         
            endif   
   
         endif
   
         
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei j��d� py�rim��n kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
           
            
      loop
  
  
   endselect
  
  
  
   goto automaatti                             ; Aloitetaan koko systeemi alusta.
   


kaytaVasenta2:

   high vasenM
         
   pause 10
   
   low vasenM
         
   return
   
   
   
kaytaOikeaa2:

   high oikeaM
         
   pause 10
   
   low oikeaM
         
   return
   
   
   
kaytaMolempia2:
   
   high vasenM, oikeaM
         
   pause 10
   
   low vasenM, oikeaM 
   
   return
   
   
   
   
manuaalinen:          ; T�ss� on manuaalisen infrapunaohjauksen koodi. Manuaaliohjauksella p��st��n hieman
                      ; kovempaa, koska low + pause komentoja ei (turhaan) ole v�liss�.
   
   irin [100, pysaytys], infVastOt, viesti   ; 100:n tilalle voi laittaa jotain pienemp��kin tarvittaessa, jolloin
                                             ; liike loppuu viel� nopeammin kun painonapit p��stet��n yl�s
                                             ; ohjaimesta(Ainakin t�h�n ohjelmaan tehdyn l�hettimen tapauksessa)
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
      
       infAikaVali = time - infAika
       
       if infAikaVali >=2 then  
        
          infAika = time 
          
          viimHav = 0       ; Nollataan viimHav, jotta jatketaan suoraan automaattiohjauksen alkaessa uudelleen,
                            ; jos ollaan vaalealla.
          goto automaatti
         
       endif   
   
   
     ;else                   T�t� ei varmaan tarvita!
   
       ;low vasenM, oikeaM
      
                                                            
   endselect                   
    	                               
   
   goto manuaalinen
                        		  

pysaytys:

   low vasenM, oikeaM

   goto manuaalinen
  
  
 