kbled %00000000

symbol suunta = b1

suunta = "p"


main:

   kbin[200, pysaytys], b0

   select b0

      case $75

         high B.1, B.4

         if suunta != "e" then

            suunta = "e"

            pause 300

         endif

      case $6B

         low B.1
         
         high B.4
         
         if suunta != "v" then

            suunta = "v"

            pause 300

         endif
         
      case $74
      
         low B.4
         
         high B.1
         
         if suunta != "o" then

            suunta = "o"

            pause 300

         endif
        
      else
      
         goto pysaytys  
         
   endselect

   

   goto main
   
   
   
pysaytys:

  low B.1, B.4
 
  suunta = "p"
 
  goto main