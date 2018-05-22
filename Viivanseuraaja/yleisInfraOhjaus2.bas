; Ohjelman nimi: yleisInfraOhjaus2.bas

; Tekijä: Olli Pulkkinen

; Tehty: 12.2.2013


; Toinen ohjelma viivanseuraajan ajamiseen, jonka myös pitäisi toimia millä tahansa IR-säätimellä.
; Ohjaamiseen voi käyttää mitä tahansa säätimen nappia. 

; Ohjaus toimii seuraavasti: Yhdellä nopealla painalluksella aletaan pyöriä vasemmalle ja 
; nopealla kaksoispainalluksella aletaan pyöriä oikealle. Suoraan päästään pitämällä nappia pohjassa jonkin aikaa. 
; Viivanseuraaja voidaan pysäyttää samoilla komennoilla kuin päästiin liikkeellekin. Jos mennään
; suoraan, saa seuraajan pysäytettyä pitämällä ohjaimen nappia pohjassa riittävän pitkään. Vasemmalle pyörittäessä voi-
; daan pysähtyä painamalla nappia kerran nopeasti, oikealle pyörittäessä pysähtyminen onnistuu puolestaan nopealla
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