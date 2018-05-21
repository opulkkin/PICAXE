' Ajanotto PICAXE 40X2:lla infrapunaportteja k�ytt�en. T�ll� ohjelmalla maksimi mittausaika on n. 4,6 s.
'
' Olli Pulkkinen
'
' 26.3.2016
'
' T�ss� ohjelmassa olisi siis tarkoitus k�ytt�� hintsetup- ja setintflags-komentoja.
' N�ill� saadaan interrupt tiettyyn jalkaan ja timerin ylivuodon interrupt yhdistetty� k�tev�sti.
' Testaamalla havaittiin ett� t�m� ohjelma mittaa aikaa tarkemmin kuin muut ohjelmaversiot.
' 
' Yksinkertaisin ohjelma mittauksen tekemiseen olisi sellainen, jossa ensin odotetaan do loop-silmukassa
' l�ht�valoportin "l�ht�signaalia", ja kun l�ht�signaali tulee k�ynnistet��n ajanotto. T�m�n j�lkeen
' ment�isiin toiseen do-loop-silmukkaan odottamaan maalivaloportin "maalisignaalia", ja maalisignaalin tullessa
' lopetettaisiin ajanotto.
' Testaamalla havaittiin, ett� hintsetup- ja setintflags-komentoja k�ytt�v�ll� ohjelmalla p��st��n kuitenkin 
' parempaan mittaustarkkuuteen.
'
'
' T�ss� ohjelmassa on valittu niin ett� ajanotto alkaa kun B.0-pinni nousee high-tilaan
' ja ajanotto loppuu kun B.1-pinni nousee high-tilaan.
'




alustukset:

   setfreq em32       ' ulkoinen 8MHz:n resonaattori k�ytt��n. Lopullinen kellotaajuus on siis nyt 32 MHz.

   pause 2000
   
   disconnect        ' laitetaan ohjelmalatauksen tarkistus pois p��lt�, koska t�st�
                     ' saattaa tulla ylim��r�ist� mittausvirhett�.
   
   
   'infrapunaportit ovat B.0:ssa ja B.1:ss�. Muut pinnit joita k�ytet��n:
   
   
   symbol vihreaLedi = B.3     
   
  
   symbol merkkiLediStart = B.4   
   
  
   symbol merkkiLediMaali = B.5
  
   
   symbol nollauskytkin = pinB.7
   
   ' 7-segmenttin�yt�ille tulostaminen hoidetaan D-, C- ja A-porttien avulla.
   
   
   ' Muutamia apumuuttujia joita k�ytet��n ajanotossa ja ajan laskemisessa(mittaustuloksen muuttaminen sekunneiksi).
   
   symbol muistiNro = b30
  

   symbol ajanOttoAloitettu = b49

   ajanOttoAloitettu = 0    ' Olisi 0 my�s ilman t�t� sijoituslausetta, mutta ohjelman ymm�rt�minen
                            ' saatta helpottua kun alkuarvo n�kyy selv�sti.
   
   symbol aika = w27
   
   
   let dirsD = %11111111  ' N�m�  letdirs-komennot ovat 7-segmenttin�ytt�j� varten. 
                          ' Kaikki D-, C- ja A- portin pinnit valitaan ulostuloiksi.
   let dirsC = %11111111

   let dirsA = %11111111 
 
  ' Ei k�ytet� A.4:sta 7-segmenttin�yt�ille, koska se on serout-pinni. J�tet��n k�ytt�m�tt� my�s pinni C.4,
  ' mutta D.4 k�ytet��n desimaalipisteen tulostamiseen.
  ' K�ytet��n siis D-porttia sekunneille, C-porttina kymmenesosille ja A-porttia sadasosille.
   
   
  ' Menn��n aluksi aliohjelmaan herkkyysSaato, jossa voidaan s��t�� fototransistoreiden kanssa sajassa olevien
  ' s��t�vastusten arvot sopiviksi. Kun painetaan nollauskytkint�(pinB.7), niin p��st��n aloittamaan ajanotto.
   
   
   gosub herkkyysSaato
   
  
  ' Tyhjennet��n 7-segmenttin�yt�t. N�yt�t nollataan kyll� ohjelman alussa my�s ilman t�t� lausetta, mutta
  ' tuleepahan selv�ksi ett� alussa n�yt�iss� ei pit�isi n�ky� mit��n.
  
   gosub tyhjennaNaytot 
 
  
  ' pause 4000
  
    
   settimer off
      
   timer = 0
  
  
   ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun n�iden komentojen j�lkeen
   ' pinniss� B.0 tapahtuu siirtym� 0 -> 1, niin hyp�t��n eritt�in nopeasti interrupt-aliohjelmaan.
   
   
   hintsetup %00010001
   
   setintflags %00000001, %00000001
   
   
   'Vihre� ledi palaa aina merkkin� siit�, ett� ollaan valmiina ottamaan uusi aika.
  
   high vihreaLedi
   
   
main:
                ' P��ohjelmassa ei tehd� mit��n muuta kuin py�rit��n rinki� ja odotetaan
                ' interruptia. Vaikuttaa aika hassulta, mutta testien perusteella t�m� on nopein
                ' tapa reagoida pinnin tilan muuttumiseen!               
   goto main
   

interrupt:

  
   if ajanOttoAloitettu = 0 then  ' T�m� if lauseke suoritetaan jos ajanottoa ei ole aloitettu
                                  ' T�t� if-lauseketta vastaava else suoritetaan jos ajanotto aon aloitettu.
      
      
                              ' Nyt siis pit�isi k�ynnist�� ajanotto. Tarkin mahdollinen menetelm�
                              ' ajanottoon on k�ytt�� settimer komentoa ja mahdollisimman suurta
                              ' preload-arvoa komennossa. Timer3:n k�ytt� olisi toinen vaihtoehto, mutta
                              ' mittaustarkkuus ei ole silloin yht� hyv�.
      
      pause 28                ' Kalibrointipause. Jostain syyst� mittausajat ovat hieman liian
                              ' pitki� vaikka luulisi niiden olevan hieman liian lyhyit�, koska
                              ' alunperin kalibrointi tehty s.e. settimer on ollut jo asetettuna
                              ' kun alkuaika on otettu. Nyth�n nimitt�in ajanoton alussa 
                              ' vasta alustetaan timer! senkin luulisi viev�n aikaa...
     
     
      settimer 65531          ' Havaittiin ett� settimer ei toimi 65531:st� suuremmilla preload-arvoilla.
   	                        ' Siis 65531 on maksimiarvo t�ss�(Manuaali ei tiennyt t�st� mit��n...:) ).
                              ' T�ll� arvolla saadaan tarkin mahdollinen mittaus.
      
      
      low vihreaLedi          ' Kun ajanotto k�ynnistyy, niin sammutetaan vihre� ledi.
      
      
      ajanOttoAloitettu = 1   ' Asetetaan 1:ksi merkkin� siit� ett� ajanotto on p��ll�.
     
     
     
      flags = %00000000       ' Lippubitit eiv�t nollaudu automaattisesti.
     
      
      ' Seuraavien komentojen suorituksen j�lkeen(ja interruptista poistumisen j�lkeen) aliohjelmaan
      ' interrupt hyp�t��n takaisin jos pinni B.1 siirtyy 0 -> 1 tai timerissa tulee ylivuoto (65535 -> 0). 
      ' Ylivuototilanne tulee n. 4,6 s kuluttua mittaamisen aloituksesta.
     
      hintsetup %00100010
   
      setintflags OR %10000010, %10000010
   
    
   
   else              ' T�m� suoritetaan siis jos ajanotto on aiemmin aloitettu.
      
      aika = timer   ' Otetaan v�litt�m�sti timerin lukema muistiin.
      
      ajanOttoAloitettu = 0
      
      
      if toflag = 1 then  'jos timerissa ylivuoto
      
         settimer off
     
         timer = 0 
         
         low vihreaLedi
         
         sertxd("ylivuoto timerissa", 13, 10) 'Tietokoneelle l�hetet��n teksti "ylivuoto timerissa"
         
         'tulostetaan 7-segmenttin�yt�olle kolme viivaa merkkin� siit� ett� aikaa ei saatu mitattua.
         
         gosub tulostaViivat
         
           
      else               ' T�m� suoritetaan jos aika on saatu normaalisti mitattua.
      
         settimer off
      
         timer = 0
      
         w4 = aika       ' Sijoitetaan aika muistipaikkaan W4. T�m� siksi, ett� aiemmin tekem�ni ohjelma
                         ' (joka muuttaa timerin lukeman sekunneiksi) k�ytti w4:sta, ja en alkanut muokkaamaan
                         ' sit�.
        
         gosub laskeAikaJaLaheta  ' LaskeAikaJaLaheta muuttaa mitatun timerin lukeman sekunneiksi ja py�rist��
                                  ' tuloksen kahden desimaalin tarkkuudelle. Tulos l�hetet��n tietokoneelle sek�
                                  ' tarkkana ett� py�ristettyn� ja 7- segmenttin�yt�ille tulostetaan py�ristetty
                                  ' lukema.
         
         'pause 1000                
      
         
      endif
      
      ' J��d��n py�rim��n silmukkaan siihen asti kunnes painetaan nollauskytkint�.
         
      do
         
         
      loop until nollauskytkin = 1
      
      
      gosub tyhjennaNaytot  ' Tyhjennet��n 7-segmenttin�yt�t.
       
     
      high vihreaLedi       ' Laitetaan vihre� ledi palamaan merkkin� siit�, ett� voidaan mitata uusi aika.
      
     
      flags = %00000000     ' Lippubitit eiv�t nollaudu automaattisesti.
   
      ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun n�iden komentojen j�lkeen
      ' (ja interrupt-aliohjelmasta poistumisen j�lkeen) pinniss� B.0 tapahtuu siirtym� 0 -> 1, niin hyp�t��n 
      ' eritt�in nopeasti takaisin  interrupt-aliohjelmaan.
   
      hintsetup %00010001
   
      setintflags %00000001, %00000001
   
   endif 
   
   
   return





laskeAikaJaLaheta:

   ' T�ss� aliohjelmassa lasketaan PICAXEn timerin muutosta vastaava aika sekunteina ja l�hetet��n
   ' tulos tietokoneelle(tarkka lukema ja kahden desimaalin tarkkuudelle py�ristetty lukema) ja kahden desimaalin
   ' tarkkuudelle py�ristetty lukema laitetaan my�s 7-segmenttin�yt�ille.

   ' Havaittiin, ett� pit�� laskea 0,070466459*x + 1,322745133, miss� x on timerin lukeman muutos, 
   ' joka on nyt w4:ssa. T�m� antaa todellisen ajan millisekunteina. Nyt siis 0 <= x <= 65535
   ' Kaava l�ydettiin mittaamalla kymmeni�tuhansia eri timerin muutoksia vastaavia aikoja tietokoneella,
   ' ja tekem�ll� havaintoaineistolle pns-sovitus(Siis kymmeni�tuhansia mittauksia ei tietenk��n tehty yksi
   ' kerrallaan vaan mittauksia varten tehtiin oma ohjelmansa PICAXElle ja toinen tietokoneelle jotka hoitivat 
   ' mittamisen ja tietokoneen ohjelma kirjoitti mittaustulokset tiedostoon tietokoneelle.). T�ll�in havaittiin, 
   ' ett� mittaustulokset asettuivat hyvin tarkasti samalle suoralle ja sovituksesta saatiin kulmakerroin ja vakiotermi,
   ' joiden avulla aika voidaan laskea kun timerin muutos tiedet��n.
   '
   ' Voidaan luonnolllisesti laskea my�s 70466459*x + 1322745133, mist� saadaan aika yksik�ss�
   ' 10^(-9) ms. Lopuksi tietokoneelle l�hetyksess� lis�t��n pilkku oikeaan paikkaan jotta saadaan
   ' aika sekunteina.
   '
   ' Huom. settimer- komennon toteutus PICAXE- j�rjestelm�ss� on aika karkeasti virheellinen, 
   ' eli komento ei toimi k�yt�nn�ss� l�hellek��n sill� tavalla kuin sen manuaalin mukaan
   ' pit�isi toimia. Yll� esitetyn sovitussuoran aulla voidaan kuitenkin aina laskea vastaava
   ' todellinen aika kun timerin muutos on mitattu. Laskukaava antaa oikeita tuloksia vain 32MHz:n 
   ' kelllotaajuudella ja settimer-komennon preload-arvolla 65531.
   
   '
   ' Lasku suoritetaan seuraavassa numero kerrallaan(10-j�rjestelm�ss�). Viimeinen vakion lis�ys +1322745133
   ' on nyt oikeastaan turha, koska kuitenkiin vakio joudutaan etsim��n uudelleen.
   ' T�m� johtuu siit�, ett� lausekkeen 70466459*x + 1322745133 kulmakerroin ja vakio
   ' m��ritettiin alunperin hieman erilaisen ajanotto-ohjelman yhteydess�.
   ' Alkuper�isess� ohjelmassa settimer oli alustettuna jo ennen ajanoton aloitusta, mutta
   ' nyt alustus tehd��n ajanoton alkaessa.
   '
   
   ' Luonnollisesti laskentaa ei tarvitsisi tehd� aivan n�in tarkoilla luvuilla, mutta eip� tarkkuudesta
   ' mit��n haittaakaan ole. RAM muistia tarvitaan melko paljon, mutta ei haittaa koska ei sit� nyt muuhunkaan
   ' tarvita. Helpompiakin tapoja laskemiseen on varmasti olemassa. esim. jos ajatellaan kaikki luvut bin��rilukuina,
   ' niin laskennan tekeminen 16-bittisill� muistipaikoilla ja niiden valmiiksi toteutulla aritmetiikalla saattaisi
   ' onnistua melko n�pp�r�sti. Helpointa olisi luonnollisesti k�ytt�� sellaista lis�osaa, joka osaisi suoraan
   ' laskea liukuluvuilla tai suurilla kokonaisluvuilla. Seuraavassa oleva koodinp�tk� laskee kuitenkin
   ' laskun 70466459*x + 1322745133 varmasti oikein(kaikilla mahdollisilla 0 <= x <= 65535, t�m�kin on tarkis-
   ' tettu er��n tietokoneohjelman avulla joka laskee vastaavan laskun ja vertaa tuloksia kesken��n). Koodi on kuitenkin
   ' nopeasti kyh�tty ja aika vaikea ymm�rt��. Ei todellekaan hyv�� esimerkkikoodia!
   '
   
   ' kulmakertoimen ja vakoitermin numerot:

   b20 = 9  b21 = 5  b22 = 4  b23 = 6  b24 = 6  b25 = 4  b26 = 0  b27 = 7   

   b10 = 3  b11 = 3  b12 = 1  b13 = 5  b14 = 4  b15 = 7  b16 = 2  b17 = 2  b18 = 3  b19 = 1
   
   
   
   ' Lasketaan aluksi w4:n numerot erikseen muuttujiin b0 - b4   
  
   b0 = w4 % 10
   
   w4 = w4 / 10
   
   b1 = w4 % 10
   
   w4 = w4 / 10
   
   b2 = w4 % 10
   
   w4 = w4 / 10
   
   b3 = w4 % 10
   
   w4 = w4 / 10
   
   b4 = w4 % 10
   
  
  ' T�m�n j�lkeen w4:sta, ts b8:sta ja b9:sta ei en�� tarvita, ts. vapautuu muuhun k�ytt��n   
  ' K�ytett�viss� nyt b5,b6,b7,b8,b9 apumuuttujina ainakin.
  
  
  ' Havainnollistava kuva kertolaskusta:
  '
  '
  '        b27,b26,b25,b24,b23,b22,b21,b20              
  '                                                 
  '                         b4,b3,b2,b1,b0
  
  
  for b31 = 0 to 4
 
      muistiNro = 0
 
      for b32 = 20 to 28
  
         peek b31, b33
         
         peek b32, b34
         
         b35 = b33 * b34
         
         b35 = b35 + muistiNro
         
         muistiNro = b35 / 10  ' uusi muistunumero
         
         b36 = b35 % 10        ' t�m� tallennetaan
         
         ' tehd��n tallennus 14-levyisille p�tkille. T�m� helpottaa yhteenlaskua jatkossa.
         ' aloitetaan paikasta 100:
         
         b37 = b31 * 14
         
         b38 = b32 - 20
         
         b38 = 100 + b37 + b38 + b31
         
         
         poke b38, b36
         
  
      next b32
          
  next b31    
  
  ' Laitetaan viel� vakiotermin numerot paikoilleen:
  
  b33 = 0
  
  for b31 = 10 to 19
  
     peek b31, b34
  
     b32 = 170 + b33
  
     poke b32, b34
  
     inc b33
  
  next b31
  
  
 ' Nyt kaikki jatkossa tarvittavat luvut ovat muistipaikoissa 100 - 179.
 ' (tai 100 + 14*6 - 1 = 183 suurin...paikoissa 180 - 183 on nollia mutta niill� lasketaan my�s kohta) 
 
 ' Lasketaan lopullinen kertolaskun ja
 ' vakion lis�yken tulos muuttujiin b0,...,b13(tiedet��n sen olevan korkeintaan 14-pituinen) s.e. v�hiten merkitsev�
 ' numero on b0:ssa jne...
  
 ' Tehd��n siis seuraavaksi yhteenlasku:
 
   
   muistiNro = 0   
   
   
   for b20 = 0 to 13
   
      b24 = 0
   
      for b21 = 0 to 5
   
         b22 = b21 * 14 + b20 + 100    ' summataan sarakkeittain, lasketaan ensin summattavien alkioiden paikat
         
         peek b22, b23
         
         b24 = b24 + b23               ' summaus sarakkeittain
   
      next b21
   
      b24 = b24 + muistiNro            ' muistetaan lis�t� muistinumero
   
      muistiNro = b24 / 10
   
      b25 = b24 % 10
   
      poke b20, b25                    ' laitetaan lopputulos muuttujiin b0,...,,b13
       
   
   next b20
   
   ' Nyt laskenta on valmis ja lopputulos on muistipaikoissa b0,...,b13.
   ' L�hetet��n seuraavassa tarkka aika tietokoneelle.
   ' Itse asiassa onkin nyt b13 aina nolla joten ei l�hetet� sit�. b12 kertoo sekunnit, b11 kymmenesosat jne.
   ' l�hetett�v� 44 on pilkun ascii-koodi.
   
   
   sertxd(#b12,44,#b11,#b10,#b9,#b8,#b7,#b6,#b5,#b4,#b3,#b2,#b1,#b0," s", 13, 10) 
 
   
  
   ' Laitetaan viel� sekunnit(b12), kymmenesosat(b11) ja sadasosat(b10) 7 segmenttin�yt�ille.
    
   ' Tehd��n t�t� ennen kuitenkin py�ristys kahden desimaalin tarkkuudelle tavallisen py�ristyss��nn�n mukaisesti.
   ' Muut tapaukset ovat helppoja paitsi se, kun toinen desimaali(b9) on 9 ja kolmas v�lill� 5 - 9.
   
   if b9 >= 5 then
   
      if b10 < 9 then
      
         inc b10
      
      else        ' nyt siis b9 = 9
      
         b10 = 0
      
         if b11 < 9 then
         
            inc b11
         
         else      ' nyt siis b10 = 9 ja b11 = 9
         
            b11 = 0
         
            inc b12    ' tiedet��n ett� nyt varmasti 0 <= b12 <= 4
            
            
         endif
      
      endif 
   
   endif
   
   
   'Tulostetaan sadasosien tarkkuudelle py�ristetty versio nyt ensin tietokoneella.
   
   sertxd("Py�ristetty tulos: ",#b12,44,#b11,#b10," s", 13, 10)
   
   
 
   ' 
   '
   ' D-, C-, ja A-porttien jalat ja vastaavat 7-segmenttin�ytt�jen ledit.
   ' D-portti tulostaa sekunnit, C-portti kymmenesosasekunnit ja A-portti sadasosasekunnit.
   '           
   '                2
   '              ------
   '             |      |
   '            1|      |3
   '             |  0   |
   '             |------|     Desimaalipisteelle k�ytet��n D-portin 4-pinni�
   '             |      |
   '            5|      |7
   '             |      |
   '              ------ 
   '                6
   '
   '
   '
   
   
   'Laitetaan ensin sekunnit ensimm�iselle 7-segmenttin�yt�lle(kytketty D-porttiin): 
   'Periaatteessa riit�isi tarkastella vain arvot 0 <= b12 <= 4, koska b12:ssa
   'ei voi nyt olla 4:sta suurempia arvoja.
 
  
 
    select b12
   
      case 0
   
         let pinsD = %11111110
                      
      case 1
      
         let pinsD = %10011000
   
      case 2
  
         let pinsD = %01111101
   
      case 3
  
         let pinsD = %11011101
   
      case 4
  
         let pinsD = %10011011
   
      case 5
  
         let pinsD = %11010111
   
      case 6
  
         let pinsD = %11110111
   
      case 7
  
         let pinsD = %10011100
   
      case 8
  
         let pinsD = %11111111
   
      case 9
  
         let pinsD = %11011111
   
   endselect
   
   
 
   'Laitetaan sitten kymmenesosat toiselle 7-segmenttin�yt�lle(kytketty C-porttiin):
 
   select b11
   
      case 0
   
         let pinsC = %11101110
                      
      case 1
      
         let pinsC = %10001000
   
      case 2
  
         let pinsC = %01101101
   
      case 3
  
         let pinsC = %11001101
   
      case 4
  
         let pinsC = %10001011
   
      case 5
  
         let pinsC = %11000111
   
      case 6
  
         let pinsC = %11100111
   
      case 7
  
         let pinsC = %10001100
   
      case 8
  
         let pinsC = %11101111
   
      case 9
  
         let pinsC = %11001111
   
   endselect
   
   
   'Laitetaan sitten sadasosat kolmannelle 7-segmenttin�yt�lle(kytketty A-porttiin):
 
    select b10
   
      case 0
   
         let pinsA = %11101110
                      
      case 1
      
         let pinsA = %10001000
   
      case 2
  
         let pinsA = %01101101
   
      case 3
  
         let pinsA = %11001101
   
      case 4
  
         let pinsA = %10001011
   
      case 5
  
         let pinsA = %11000111
   
      case 6
  
         let pinsA = %11100111
   
      case 7
  
         let pinsA = %10001100
   
      case 8
  
         let pinsA = %11101111
   
      case 9
  
         let pinsA = %11001111
   
   endselect
  
   
   
   return
 
 
   
   
   
tyhjennaNaytot:


   
   let pinsD = %00000000

   let pinsC = %00000000
  
   let pinsA = %00000000


   return
   
   
tulostaViivat:


   let pinsD = %00000001
         
   let pinsC = %00000001
         
   let pinsA = %00000001


   return
  
   
herkkyysSaato:

   
   do
    
      if pinB.0 = 1 then
      
         high merkkiLediStart
      
      else
      
         low merkkiLediStart
      
      endif   
    
    
      if pinB.1 = 1 then
      
         high merkkiLediMaali
      
      else
      
         low merkkiLediMaali
      
      endif 
         
         
   loop until nollauskytkin = 1


   return  