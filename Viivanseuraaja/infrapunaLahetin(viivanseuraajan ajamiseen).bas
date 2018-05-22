; Ohjelman nimi: infrapunaLahetin.bas

; Tekij‰: Olli Pulkkinen

; Tehty: 22.12.2012


; T‰m‰ ohjelma on tarkoitettu picaxeen, joka l‰hett‰‰ nelj‰‰ eri infrapunakomentoja esim.toiselle
; picaxelle. Jotta l‰hetett‰v‰t komennot sopivat esim. robottiauton ajamiseen ja olisivat
; mukavasti yhteensopivia tv-kaukos‰‰timen kanssa , niin k‰ytet‰‰n sellaisia infrapunakomentoja,
; ett‰ televisiokaukos‰‰timell‰nohjattaessa 2 = ylˆs, 8 = alas, 4 = vasemmalle ja 6 = oikealle.  
; Viivanseuraa ajettaessa koodisanalla 7 l‰hetet‰‰n tieto automaatti ja manuaaliohjauksen
; vaihtamisesta.
 
; Koska tv-kaukos‰‰timet pit‰v‰n n. 45 ms tauon signaalien l‰hett‰misess‰, jos nappia pidet‰‰n pohjassa, niin  
; ne eiv‰t sellaisenaan sovi hyvin yhteen kaikkien viivanseuraajan ajoon tarkoitettujen ohjelmien kanssa. Nappia saattaa
; joutua n‰pytt‰m‰‰n useampia kertoja ennen kuin viesti menee perille. T‰m‰ ohjelma sen sijaan toimii melko hyvin
; kaikkien viivanseuraajaohjelmien kanssa.


main:

  
   pause 45            ; T‰m‰ tauko tulee siis v‰hint‰‰n v‰liin vaikka nappia pidet‰‰n pohjassa.
                       ; Tauon pituutta saattaa joutua muuttamaan. Kuitenkaan pitk‰ tauko (esim. 45 ms) ei toimi
                       ; kovin hyvin ja t‰m‰ johtuu luonnollisesti vastaanotto-ohjelman rakenteesta, jossa 
                       ; infrapunasignaalia voidaan odottaa kerrallaan vain 5 ms. Myˆsk‰‰n pausen pois j‰‰tt‰minen 
                       ; kokonaan ei toiminut kovin hyvin. Kokeile!
   if pin3 = 1 then        
                           ; Jos nappeja on yht‰aikaa pohjassa, niin t‰rkein l‰hetett‰v‰
                           ; on t‰ss‰ ensimm‰isen‰ ja sen on valittu olevan 8 = alas(koodi 7). 
      irout 0, 1, 7        ; Seuraavaksi tulee ylˆs = 2 (koodi 1), sitten vasemmalle = 4(koodi 3)
                           ; ja viimeisen‰ oikealle = 6(koodi 5).
      goto main
                         
   endif
   
   
   
                     
   if pin2 = 1 then
                           
      irout 0, 1, 1        
                           
      goto main            
                           
   endif
                                
   
   
   if pin1 = 1 then
   
      irout 0, 1, 3        
        
      goto main
                         
   endif;   
   
   if pin4 = 1 then
   
      irout 0, 1, 5        
        
      goto main
                         
   endif;
   
   goto main
   
   
