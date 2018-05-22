; Ohjelman nimi: yleisInfraOhjaus2.bas

; Tekij�: Olli Pulkkinen

; Tehty: 12.2.2013


; Toinen ohjelma viivanseuraajan ajamiseen, jonka my�s pit�isi toimia mill� tahansa IR-s��timell�.
; Ohjaamiseen voi k�ytt�� mit� tahansa s��timen nappia. 

; Ohjaus toimii seuraavasti: Yhdell� nopealla painalluksella aletaan py�ri� vasemmalle ja 
; nopealla kaksoispainalluksella aletaan py�ri� oikealle. Suoraan p��st��n pit�m�ll� nappia pohjassa jonkin aikaa. 
; Viivanseuraaja voidaan pys�ytt�� samoilla komennoilla kuin p��stiin liikkeellekin. Jos menn��n
; suoraan, saa seuraajan pys�ytetty� pit�m�ll� ohjaimen nappia pohjassa riitt�v�n pitk��n. Vasemmalle py�ritt�ess� voi-
; daan pys�hty� painamalla nappia kerran nopeasti, oikealle py�ritt�ess� pys�htyminen onnistuu puolestaan nopealla
; tuplapainalluksella. 


symbol vasenM = B.1

symbol oikeaM = B.4


symbol suunta = b1

suunta = 0

symbol laskuri = b2
  

main:

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
         
         else
            
            high oikeaM, vasenM
            
            suunta = 3
         
         endif
         
         pause 500
   
   endselect
   
   
   
   goto main