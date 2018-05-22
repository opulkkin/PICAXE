; Ohjelman nimi: yleisInfraOhjaus1.bas

; Tekij‰: Olli Pulkkinen

; Tehty: 10.2.2013

; Ohjauksen pit‰isi toimia mill‰ tahansa IR-kaukios‰‰timell‰. Ensimm‰isen kerran nappia painettaessa
; l‰hdet‰‰n eteenp‰in, toisella painalluksella vasemmalle, kolmannella oikealle ja nelj‰nnell‰ 
; pys‰ytet‰‰n jne...



b0 = 0

main:


  if pinC.0 = 0 and b0 = 3 then
  
     low B.1, B.4
  
     pause 150
  
     b0 = 0
  
  endif


  if pinC.0 = 0 and b0 = 0 then
  
     high B.1, B.4
  
     pause 150
  
     inc b0
  
  endif
  
  if pinC.0 = 0 and b0 = 1 then
  
     low B.1
  
     high B.4
  
     pause 150
     
     inc b0
  
  endif
  
  if pinC.0 = 0 and b0 = 2 then
  
     low B.4
  
     high B.1
  
     pause 150
     
     inc b0
  
  endif
  
  goto main
  

