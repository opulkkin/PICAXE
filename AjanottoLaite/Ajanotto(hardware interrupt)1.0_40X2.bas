' Ajanotto PICAXE 40X2:lla infrapunaportteja käyttäen. Tällä ohjelmalla maksimi mittausaika on n. 4,6 s.
'
' Olli Pulkkinen
'
' 26.3.2016
'
' Tässä ohjelmassa olisi siis tarkoitus käyttää hintsetup- ja setintflags-komentoja.
' Näillä saadaan interrupt tiettyyn jalkaan ja timerin ylivuodon interrupt yhdistettyä kätevästi.
' Testaamalla havaittiin että tämä ohjelma mittaa aikaa tarkemmin kuin muut ohjelmaversiot.
' 
' Yksinkertaisin ohjelma mittauksen tekemiseen olisi sellainen, jossa ensin odotetaan do loop-silmukassa
' lähtövaloportin "lähtösignaalia", ja kun lähtösignaali tulee käynnistetään ajanotto. Tämän jälkeen
' mentäisiin toiseen do-loop-silmukkaan odottamaan maalivaloportin "maalisignaalia", ja maalisignaalin tullessa
' lopetettaisiin ajanotto.
' Testaamalla havaittiin, että hintsetup- ja setintflags-komentoja käyttävällä ohjelmalla päästään kuitenkin 
' parempaan mittaustarkkuuteen.
'
'
' Tässä ohjelmassa on valittu niin että ajanotto alkaa kun B.0-pinni nousee high-tilaan
' ja ajanotto loppuu kun B.1-pinni nousee high-tilaan.
'




alustukset:

   setfreq em32       ' ulkoinen 8MHz:n resonaattori käyttöön. Lopullinen kellotaajuus on siis nyt 32 MHz.

   pause 2000
   
   disconnect        ' laitetaan ohjelmalatauksen tarkistus pois päältä, koska tästä
                     ' saattaa tulla ylimääräistä mittausvirhettä.
   
   
   'infrapunaportit ovat B.0:ssa ja B.1:ssä. Muut pinnit joita käytetään:
   
   
   symbol vihreaLedi = B.3     
   
  
   symbol merkkiLediStart = B.4   
   
  
   symbol merkkiLediMaali = B.5
  
   
   symbol nollauskytkin = pinB.7
   
   ' 7-segmenttinäytöille tulostaminen hoidetaan D-, C- ja A-porttien avulla.
   
   
   ' Muutamia apumuuttujia joita käytetään ajanotossa ja ajan laskemisessa(mittaustuloksen muuttaminen sekunneiksi).
   
   symbol muistiNro = b30
  

   symbol ajanOttoAloitettu = b49

   ajanOttoAloitettu = 0    ' Olisi 0 myös ilman tätä sijoituslausetta, mutta ohjelman ymmärtäminen
                            ' saatta helpottua kun alkuarvo näkyy selvästi.
   
   symbol aika = w27
   
   
   let dirsD = %11111111  ' Nämä  letdirs-komennot ovat 7-segmenttinäyttöjä varten. 
                          ' Kaikki D-, C- ja A- portin pinnit valitaan ulostuloiksi.
   let dirsC = %11111111

   let dirsA = %11111111 
 
  ' Ei käytetä A.4:sta 7-segmenttinäytöille, koska se on serout-pinni. Jätetään käyttämättä myös pinni C.4,
  ' mutta D.4 käytetään desimaalipisteen tulostamiseen.
  ' Käytetään siis D-porttia sekunneille, C-porttina kymmenesosille ja A-porttia sadasosille.
   
   
  ' Mennään aluksi aliohjelmaan herkkyysSaato, jossa voidaan säätää fototransistoreiden kanssa sajassa olevien
  ' säätövastusten arvot sopiviksi. Kun painetaan nollauskytkintä(pinB.7), niin päästään aloittamaan ajanotto.
   
   
   gosub herkkyysSaato
   
  
  ' Tyhjennetään 7-segmenttinäytöt. Näytöt nollataan kyllä ohjelman alussa myös ilman tätä lausetta, mutta
  ' tuleepahan selväksi että alussa näytöissä ei pitäisi näkyä mitään.
  
   gosub tyhjennaNaytot 
 
  
  ' pause 4000
  
    
   settimer off
      
   timer = 0
  
  
   ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun näiden komentojen jälkeen
   ' pinnissä B.0 tapahtuu siirtymä 0 -> 1, niin hypätään erittäin nopeasti interrupt-aliohjelmaan.
   
   
   hintsetup %00010001
   
   setintflags %00000001, %00000001
   
   
   'Vihreä ledi palaa aina merkkinä siitä, että ollaan valmiina ottamaan uusi aika.
  
   high vihreaLedi
   
   
main:
                ' Pääohjelmassa ei tehdä mitään muuta kuin pyöritään rinkiä ja odotetaan
                ' interruptia. Vaikuttaa aika hassulta, mutta testien perusteella tämä on nopein
                ' tapa reagoida pinnin tilan muuttumiseen!               
   goto main
   

interrupt:

  
   if ajanOttoAloitettu = 0 then  ' Tämä if lauseke suoritetaan jos ajanottoa ei ole aloitettu
                                  ' Tätä if-lauseketta vastaava else suoritetaan jos ajanotto aon aloitettu.
      
      
                              ' Nyt siis pitäisi käynnistää ajanotto. Tarkin mahdollinen menetelmä
                              ' ajanottoon on käyttää settimer komentoa ja mahdollisimman suurta
                              ' preload-arvoa komennossa. Timer3:n käyttö olisi toinen vaihtoehto, mutta
                              ' mittaustarkkuus ei ole silloin yhtä hyvä.
      
      pause 28                ' Kalibrointipause. Jostain syystä mittausajat ovat hieman liian
                              ' pitkiä vaikka luulisi niiden olevan hieman liian lyhyitä, koska
                              ' alunperin kalibrointi tehty s.e. settimer on ollut jo asetettuna
                              ' kun alkuaika on otettu. Nythän nimittäin ajanoton alussa 
                              ' vasta alustetaan timer! senkin luulisi vievän aikaa...
     
     
      settimer 65531          ' Havaittiin että settimer ei toimi 65531:stä suuremmilla preload-arvoilla.
   	                        ' Siis 65531 on maksimiarvo tässä(Manuaali ei tiennyt tästä mitään...:) ).
                              ' Tällä arvolla saadaan tarkin mahdollinen mittaus.
      
      
      low vihreaLedi          ' Kun ajanotto käynnistyy, niin sammutetaan vihreä ledi.
      
      
      ajanOttoAloitettu = 1   ' Asetetaan 1:ksi merkkinä siitä että ajanotto on päällä.
     
     
     
      flags = %00000000       ' Lippubitit eivät nollaudu automaattisesti.
     
      
      ' Seuraavien komentojen suorituksen jälkeen(ja interruptista poistumisen jälkeen) aliohjelmaan
      ' interrupt hypätään takaisin jos pinni B.1 siirtyy 0 -> 1 tai timerissa tulee ylivuoto (65535 -> 0). 
      ' Ylivuototilanne tulee n. 4,6 s kuluttua mittaamisen aloituksesta.
     
      hintsetup %00100010
   
      setintflags OR %10000010, %10000010
   
    
   
   else              ' Tämä suoritetaan siis jos ajanotto on aiemmin aloitettu.
      
      aika = timer   ' Otetaan välittömästi timerin lukema muistiin.
      
      ajanOttoAloitettu = 0
      
      
      if toflag = 1 then  'jos timerissa ylivuoto
      
         settimer off
     
         timer = 0 
         
         low vihreaLedi
         
         sertxd("ylivuoto timerissa", 13, 10) 'Tietokoneelle lähetetään teksti "ylivuoto timerissa"
         
         'tulostetaan 7-segmenttinäytöolle kolme viivaa merkkinä siitä että aikaa ei saatu mitattua.
         
         gosub tulostaViivat
         
           
      else               ' Tämä suoritetaan jos aika on saatu normaalisti mitattua.
      
         settimer off
      
         timer = 0
      
         w4 = aika       ' Sijoitetaan aika muistipaikkaan W4. Tämä siksi, että aiemmin tekemäni ohjelma
                         ' (joka muuttaa timerin lukeman sekunneiksi) käytti w4:sta, ja en alkanut muokkaamaan
                         ' sitä.
        
         gosub laskeAikaJaLaheta  ' LaskeAikaJaLaheta muuttaa mitatun timerin lukeman sekunneiksi ja pyöristää
                                  ' tuloksen kahden desimaalin tarkkuudelle. Tulos lähetetään tietokoneelle sekä
                                  ' tarkkana että pyöristettynä ja 7- segmenttinäytöille tulostetaan pyöristetty
                                  ' lukema.
         
         'pause 1000                
      
         
      endif
      
      ' Jäädään pyörimään silmukkaan siihen asti kunnes painetaan nollauskytkintä.
         
      do
         
         
      loop until nollauskytkin = 1
      
      
      gosub tyhjennaNaytot  ' Tyhjennetään 7-segmenttinäytöt.
       
     
      high vihreaLedi       ' Laitetaan vihreä ledi palamaan merkkinä siitä, että voidaan mitata uusi aika.
      
     
      flags = %00000000     ' Lippubitit eivät nollaudu automaattisesti.
   
      ' Seuraavat kaksi komentoa alustavat hardware interruptin pinniin B.0. Kun näiden komentojen jälkeen
      ' (ja interrupt-aliohjelmasta poistumisen jälkeen) pinnissä B.0 tapahtuu siirtymä 0 -> 1, niin hypätään 
      ' erittäin nopeasti takaisin  interrupt-aliohjelmaan.
   
      hintsetup %00010001
   
      setintflags %00000001, %00000001
   
   endif 
   
   
   return





laskeAikaJaLaheta:

   ' Tässä aliohjelmassa lasketaan PICAXEn timerin muutosta vastaava aika sekunteina ja lähetetään
   ' tulos tietokoneelle(tarkka lukema ja kahden desimaalin tarkkuudelle pyöristetty lukema) ja kahden desimaalin
   ' tarkkuudelle pyöristetty lukema laitetaan myös 7-segmenttinäytöille.

   ' Havaittiin, että pitää laskea 0,070466459*x + 1,322745133, missä x on timerin lukeman muutos, 
   ' joka on nyt w4:ssa. Tämä antaa todellisen ajan millisekunteina. Nyt siis 0 <= x <= 65535
   ' Kaava löydettiin mittaamalla kymmeniätuhansia eri timerin muutoksia vastaavia aikoja tietokoneella,
   ' ja tekemällä havaintoaineistolle pns-sovitus(Siis kymmeniätuhansia mittauksia ei tietenkään tehty yksi
   ' kerrallaan vaan mittauksia varten tehtiin oma ohjelmansa PICAXElle ja toinen tietokoneelle jotka hoitivat 
   ' mittamisen ja tietokoneen ohjelma kirjoitti mittaustulokset tiedostoon tietokoneelle.). Tällöin havaittiin, 
   ' että mittaustulokset asettuivat hyvin tarkasti samalle suoralle ja sovituksesta saatiin kulmakerroin ja vakiotermi,
   ' joiden avulla aika voidaan laskea kun timerin muutos tiedetään.
   '
   ' Voidaan luonnolllisesti laskea myös 70466459*x + 1322745133, mistä saadaan aika yksikössä
   ' 10^(-9) ms. Lopuksi tietokoneelle lähetyksessä lisätään pilkku oikeaan paikkaan jotta saadaan
   ' aika sekunteina.
   '
   ' Huom. settimer- komennon toteutus PICAXE- järjestelmässä on aika karkeasti virheellinen, 
   ' eli komento ei toimi käytännössä lähellekään sillä tavalla kuin sen manuaalin mukaan
   ' pitäisi toimia. Yllä esitetyn sovitussuoran aulla voidaan kuitenkin aina laskea vastaava
   ' todellinen aika kun timerin muutos on mitattu. Laskukaava antaa oikeita tuloksia vain 32MHz:n 
   ' kelllotaajuudella ja settimer-komennon preload-arvolla 65531.
   
   '
   ' Lasku suoritetaan seuraavassa numero kerrallaan(10-järjestelmässä). Viimeinen vakion lisäys +1322745133
   ' on nyt oikeastaan turha, koska kuitenkiin vakio joudutaan etsimään uudelleen.
   ' Tämä johtuu siitä, että lausekkeen 70466459*x + 1322745133 kulmakerroin ja vakio
   ' määritettiin alunperin hieman erilaisen ajanotto-ohjelman yhteydessä.
   ' Alkuperäisessä ohjelmassa settimer oli alustettuna jo ennen ajanoton aloitusta, mutta
   ' nyt alustus tehdään ajanoton alkaessa.
   '
   
   ' Luonnollisesti laskentaa ei tarvitsisi tehdä aivan näin tarkoilla luvuilla, mutta eipä tarkkuudesta
   ' mitään haittaakaan ole. RAM muistia tarvitaan melko paljon, mutta ei haittaa koska ei sitä nyt muuhunkaan
   ' tarvita. Helpompiakin tapoja laskemiseen on varmasti olemassa. esim. jos ajatellaan kaikki luvut binäärilukuina,
   ' niin laskennan tekeminen 16-bittisillä muistipaikoilla ja niiden valmiiksi toteutulla aritmetiikalla saattaisi
   ' onnistua melko näppärästi. Helpointa olisi luonnollisesti käyttää sellaista lisäosaa, joka osaisi suoraan
   ' laskea liukuluvuilla tai suurilla kokonaisluvuilla. Seuraavassa oleva koodinpätkä laskee kuitenkin
   ' laskun 70466459*x + 1322745133 varmasti oikein(kaikilla mahdollisilla 0 <= x <= 65535, tämäkin on tarkis-
   ' tettu erään tietokoneohjelman avulla joka laskee vastaavan laskun ja vertaa tuloksia keskenään). Koodi on kuitenkin
   ' nopeasti kyhätty ja aika vaikea ymmärtää. Ei todellekaan hyvää esimerkkikoodia!
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
   
  
  ' Tämän jälkeen w4:sta, ts b8:sta ja b9:sta ei enää tarvita, ts. vapautuu muuhun käyttöön   
  ' Käytettävissä nyt b5,b6,b7,b8,b9 apumuuttujina ainakin.
  
  
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
         
         b36 = b35 % 10        ' tämä tallennetaan
         
         ' tehdään tallennus 14-levyisille pätkille. Tämä helpottaa yhteenlaskua jatkossa.
         ' aloitetaan paikasta 100:
         
         b37 = b31 * 14
         
         b38 = b32 - 20
         
         b38 = 100 + b37 + b38 + b31
         
         
         poke b38, b36
         
  
      next b32
          
  next b31    
  
  ' Laitetaan vielä vakiotermin numerot paikoilleen:
  
  b33 = 0
  
  for b31 = 10 to 19
  
     peek b31, b34
  
     b32 = 170 + b33
  
     poke b32, b34
  
     inc b33
  
  next b31
  
  
 ' Nyt kaikki jatkossa tarvittavat luvut ovat muistipaikoissa 100 - 179.
 ' (tai 100 + 14*6 - 1 = 183 suurin...paikoissa 180 - 183 on nollia mutta niillä lasketaan myös kohta) 
 
 ' Lasketaan lopullinen kertolaskun ja
 ' vakion lisäyken tulos muuttujiin b0,...,b13(tiedetään sen olevan korkeintaan 14-pituinen) s.e. vähiten merkitsevä
 ' numero on b0:ssa jne...
  
 ' Tehdään siis seuraavaksi yhteenlasku:
 
   
   muistiNro = 0   
   
   
   for b20 = 0 to 13
   
      b24 = 0
   
      for b21 = 0 to 5
   
         b22 = b21 * 14 + b20 + 100    ' summataan sarakkeittain, lasketaan ensin summattavien alkioiden paikat
         
         peek b22, b23
         
         b24 = b24 + b23               ' summaus sarakkeittain
   
      next b21
   
      b24 = b24 + muistiNro            ' muistetaan lisätä muistinumero
   
      muistiNro = b24 / 10
   
      b25 = b24 % 10
   
      poke b20, b25                    ' laitetaan lopputulos muuttujiin b0,...,,b13
       
   
   next b20
   
   ' Nyt laskenta on valmis ja lopputulos on muistipaikoissa b0,...,b13.
   ' Lähetetään seuraavassa tarkka aika tietokoneelle.
   ' Itse asiassa onkin nyt b13 aina nolla joten ei lähetetä sitä. b12 kertoo sekunnit, b11 kymmenesosat jne.
   ' lähetettävä 44 on pilkun ascii-koodi.
   
   
   sertxd(#b12,44,#b11,#b10,#b9,#b8,#b7,#b6,#b5,#b4,#b3,#b2,#b1,#b0," s", 13, 10) 
 
   
  
   ' Laitetaan vielä sekunnit(b12), kymmenesosat(b11) ja sadasosat(b10) 7 segmenttinäytöille.
    
   ' Tehdään tätä ennen kuitenkin pyöristys kahden desimaalin tarkkuudelle tavallisen pyöristyssäännön mukaisesti.
   ' Muut tapaukset ovat helppoja paitsi se, kun toinen desimaali(b9) on 9 ja kolmas välillä 5 - 9.
   
   if b9 >= 5 then
   
      if b10 < 9 then
      
         inc b10
      
      else        ' nyt siis b9 = 9
      
         b10 = 0
      
         if b11 < 9 then
         
            inc b11
         
         else      ' nyt siis b10 = 9 ja b11 = 9
         
            b11 = 0
         
            inc b12    ' tiedetään että nyt varmasti 0 <= b12 <= 4
            
            
         endif
      
      endif 
   
   endif
   
   
   'Tulostetaan sadasosien tarkkuudelle pyöristetty versio nyt ensin tietokoneella.
   
   sertxd("Pyöristetty tulos: ",#b12,44,#b11,#b10," s", 13, 10)
   
   
 
   ' 
   '
   ' D-, C-, ja A-porttien jalat ja vastaavat 7-segmenttinäyttöjen ledit.
   ' D-portti tulostaa sekunnit, C-portti kymmenesosasekunnit ja A-portti sadasosasekunnit.
   '           
   '                2
   '              ------
   '             |      |
   '            1|      |3
   '             |  0   |
   '             |------|     Desimaalipisteelle käytetään D-portin 4-pinniä
   '             |      |
   '            5|      |7
   '             |      |
   '              ------ 
   '                6
   '
   '
   '
   
   
   'Laitetaan ensin sekunnit ensimmäiselle 7-segmenttinäytölle(kytketty D-porttiin): 
   'Periaatteessa riitäisi tarkastella vain arvot 0 <= b12 <= 4, koska b12:ssa
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
   
   
 
   'Laitetaan sitten kymmenesosat toiselle 7-segmenttinäytölle(kytketty C-porttiin):
 
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
   
   
   'Laitetaan sitten sadasosat kolmannelle 7-segmenttinäytölle(kytketty A-porttiin):
 
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