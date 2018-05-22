 
 
 
 symbol oikeaM = B.4           ; oikea moottori

 symbol vasenM = B.1           ; vasen moottori
   
 symbol infVastOt = C.0        ; infrapunasignaalin vastaanotto C.0:sta

 symbol viesti = b0



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
   
   else
   
      low vasenM, oikeaM                  
    	                               
   
   endselect
   
   
   goto manuaalinen
                        		  

pysaytys:

   low vasenM, oikeaM

   goto manuaalinen 