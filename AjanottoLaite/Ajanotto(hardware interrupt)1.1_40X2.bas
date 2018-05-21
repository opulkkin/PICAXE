' Ajanotto PICAXE 40X2:lla infrapunaportteja käyttäen. Tällä ohjelmalla maksimi mittausaika on n. 4,6 s.
'
' Olli Pulkkinen
'
' 31.3.2016
'
' Tässä ohjelmassa olisi siis tarkoitus käyttää hintsetup- ja setintflags-komentoja.
' Näillä saadaan interrupt tiettyyn jalkaan ja timerin ylivuodon interrupt yhdistettyä kätevästi.
' Testaamalla havaittiin että tämä ohjelma mittaa aikaa tarkemmin kuin muut ohjelmaversiot.
' 
' Ohjelma on muuten sama kuin edellinen ohjelmaversio 1.0, mutta ajan laskenta aliohjelmassa laskeAikaJaLaheta
' on tehty eri tavalla. Laskennan tulos on kuitenkin aina sama kuin edellisessä ohjelmaversiossa.
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
   
   symbol muistiNro = b53
  
   muistiNro = 0

   symbol kierrokset = b51

   kierrokset = 0


   symbol ajanOttoAloitettu = b52    ' sisältyy w26:een

   ajanOttoAloitettu = 0    ' Olisi 0 myös ilman tätä sijoituslausetta, mutta ohjelman ymmärtäminen
                            ' saatta helpottua kun alkuarvo näkyy selvästi.
   
   symbol aika = w27
   
   ' Nyt b0...b51 ovat käytettävissä muuhun tarkitukseen.
   
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
                                  ' Tätä if-lauseketta vastaava else suoritetaan jos ajanotto on aloitettu.
      
      
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
   
   
   ' Seuraavana pitäisi siis laskea lasku 70466459*x + 1322745133, missä x on timerin lukema, joka on nyt
   ' muuttujassa aika(=w27). Ongelmana on se, että PICAXE:n aritmetiikka on toteutettu vain maksimissaan
   ' 16-bittisille kokonaisluvuille, eli siis 65535 on maksimi arvo mikä voi esiintyä matemaattisissa
   ' laskutoimituksissa. Siis laskutoimitusta ei voida tehdä suoraan. On siis keksittävä jokin toinen menetelmä
   ' laskun laskemiseksi. Tosin laskua ei tarvitsisi tehdä näin suurella tarkkuudella ja laskenta helpottuisi jos
   ' operandeja hieman pyöristeltäisiin. On kuitenkin ihan mielenkiintoinen matemaattinen ja ohjelmallinen harjoitus-
   ' tehtävä laskea lasku yllä esitetyillä isoilla luvuilla(ts. "tarkoilla" arvoilla). 
   
   ' Edellisessä ohjelmaversiossa laskettiin lasku siten, että jokaiselle numerolle käytettiin
   ' omaa 8-bitin muistipaikkaa RAM-muistista ja pyöräytettiin läpi jo alakoulusta tuttu kertolaskualgoritmi.
   ' Tosin ohjelmakoodina lasku näyttää melko sekavalta ja algoritmi tuhlaa kohtuuttoman paljon muistipaikkoja eikä
   ' varmasti ole myöskään ajankäytöltään kovin hyvä!(Tosin muistia ei tarvita nyt muuhunkaan eikä laskuaikakaan ole
   ' käytännössä pitkä).
 
   ' Seuraavaavassa on ehkä järkevämpi tapa toteuttaa lasku. Siinä ajatellaan laskussa kaikki operandit
   ' binäärilukuina (tai 256-kantaisessa tai 65536-kantaisessa lukujärjestelmässä) ja suoritetaan lasku 
   ' käyttäen PICAXE:n valmista aritmetiikkaa 16-bitin luvuille(ks. manuaalin osa 2 sivulta 22 alkaen). 
   ' Menetelmä kuitenkin vaatii jonkin verran alkeellisen lukuteorian osaamista, erityisesti täytyy hallita 
   ' jakojäännöslaskentaa(jäännösluokka-aritmetiikka mod n) ja luvun esittäminen muissakin lukujärjestelmissä kuin 
   ' pelkästään tutussa 10-järjestelmässä.
   ' Lisäksi täytyy ymmärtää jakokulman algoritmi sen verran syvällisesti, että osaa käyttää sitä myös muissa kuin 
   ' 10-kantaisessa lukujärjestelmässä. Mutta mitään oikeasti syvällistä matematiikkaa ei kuitenkaan tarvita.
   ' 
   ' Etsitään aluksi laskussa esiintyvien lukua 65535 suurempien kokonaislukujen binääriesitykset ja esitykset:
   ' 256-kantaisessa ja 65526-kantaisessa lukujärjestelmässä.
   '
   '
   ' 70466459 = 2^26 + 2^21 + 2^20 + 2^17 + 2^16 + 2^13 + 2^12 + 2^11 + 2^9 + 2^8 + 2^7 + 2^4 + 2^3 + 2^1 + 2^0
   '
   '          = 100001100110011101110011011 = 4*256^3 + 51*256^2 + 59*256^1 + 155*256^0 = 004051059155 (256-järj.)
   '
   '          = 1075*65536^1 + 15259*65536^0 = 0107515259(65536-järjestelmässä)
   '
   '
   ' Yleensä lukujärjestelmissä otetaan kirjaimet käyttöön silloin kuin kantaluku > 10, mutta
   ' kun järjestelmässä on 256(tai 65536) eri merkkiä niin on ehkä järkevämpää käyttää esim. kolmen numeron jonoa
   ' yhden merkin esittämiseen. Siis 256-kantaisen lukujärjestelmän "numerot" ovat tällä merkinnällä
   ' 000,001,002,...,253,254,255. Tässä on myös se hyvä puoli, että laskenta toimii odotetulla tavalla jatkossa,
   ' koska näin määritellyille kehitelmän "numeroille" on esim. suuruusjärjestys määritelty luonnollisella tavalla.
   ' Vastaavalla tavalla on tehty 65536-järjestelmässä, missä "numerot" koostuvat 5-pituisista merkkijonoista.
   
   
   ' 1322745133 = 2^30 + 2^27 + 2^26 + 2^25 + 2^23 + 2^22 + 2^20 + 2^18 + 2^17 + 2^16 + 2^14 + 2^13 + 2^12 + 2^11 + 2^10
   '             
   '              + 2^8 + 2^5 + 2^3 + 2^2 + 2^0 = 1001110110101110111110100101101
   '
   '            = 78*256^3 + 215*256^2 + 125*256^1 + 45*256^0 = 078215125045  (256-järjestelmässä)
   '
   '            = 20183*65536^1 + 32045*65536^0 = 2018332045 (65536-järjestelmässä) 
   
   ' Kertoimen 704666459 65536-kantaisen järjestelmän "numerot" ovat 1075(enemmän merkitsevä) ja 15259(vähemmän merkitsevä)
   '
   ' Vakion 1322745133 65536-kantaisen järjestelmän "numerot" ovat 20183(enemmän merkitsevä) ja 32045(vähemmän merkitsevä)
   '
   ' Annetaan näille "vakionumeroille" nimet, jolloin ohjelman muokkaaminen helpottuu jos niitä tarvitsee joskus
   ' muuttaa. Aivan mitä tahansa arvoja ei voi näille vakioille antaa, kuten alla olevasta koodista selviää.
   
     symbol kerroin0 = 15259  ' Tämän pitää olla <=65535
     
     symbol kerroin1 = 1075   ' Tämän pitää olla <=65534
   
     symbol vakio0 = 32045    ' Tämän pitää olla <=65535
   
     symbol vakio1 = 20183    ' Tämän pitää olla <=65534
   
   ' Seuraaavana lasketaan 70466459*aika ja tallennetaan tulos kolmeen sanamuuttujaan w4, w5 ja w6.
   
   ' Kun kertolasku suoritetaan 65536-kantaisessa lukujärjestelmässä, saadaan
   ' (kerroin1*65536^1 + kerroin0*65536^0) * aika = kerroin1*aika*65536^1 + kerroin0*aika*65536^0
   ' Kun laskun kerroin1*aika 16 vähiten merkitsevää bittiä sijoitetaan muistipaikkaan w3 ja 16 eniten merkitsevää
   ' bittiä w2:iin, ja vastaavasti laskun kerroin0*aika 16 vähiten merkitsevää bittiä sijoitetaan w0:iin ja
   ' 16 eniten merkitsevää bittiä sijoitetaan w4:n saadaan laskun tulos ainakin teoriassa esitettyä muodossa
   ' w2*65536^2 + (w3 + w4)*65536^1 + w0. Tässä on vain yksi ongelma, nimittäin w3 + w4 saattaa mennä yli arvon
   ' 65535 ja tällöin ylivuotobitit menetetään ja lasku ei anna oikeaa tulosta. On kuitenkin helppo testata milloin
   ' 16 bitin aritmetiikassa tapahtuu ylivuoto laskettaessa w3 + w4. Pätee nimittäin seuraava tulos(helppo osoittaa):
 
   ' Laskettaessa w3 + w4 tapahtuu ylivuoto jos ja vain jos w3 + w4 < w3 ja w3 + w4 < w4
   '
   ' Itse asiassa ylivuoto on vielä yhtäpitävää sen kanssa että w3 + w4 < w3, mikä vastaavasti on vielä yhtäpitävää
   ' sen kanssa että w3 + w4 < w4, joten riittäisi testata esim. w3 + w4 < w3, mutta eipä se haittaa vaikka
   ' yksi turha testaus tehdäänkin.
   '
   ' Tämän avulla voidaan päätellä, että seuraava algoritmi antaa järkevän tuloksen:
   ' Sijoitetaan laskun kerroin1*aika 16 vähiten merkitsevää bittiä muistipaikkaan w3 ja 16 eniten merkitsevää
   ' bittiä w2:iin, ja vastaavasti laskun kerroin0*aika 16 vähiten merkitsevää bittiä w0:iin ja
   ' 16 eniten merkitsevää bittiä w4:een. Sijoitetaan w1 = w3 + w4. Testataan onko voimassa w1 < MIN(w3, w4)
   ' Jos tämä on voimassa, niin on tapahtunut ylivuoto, jolloin kasvatetaan w2 yhdellä. Jos tämä ei ole voimassa, niin
   ' ylivuotoa ei ole tapahtunut ja w2:lle ei tehdä mitään. 
   ' Näiden operaatioiden jälkeen laskun 70466459*aika tulos saadaan muistipaikkojen w2, w1 ja w0 avulla muodossa
   ' w2*65536^2 + w1*65536^1 + w0*65536^0.
   '
   ' Toteutetaan seuraavaksi yllä esitetty idea:
   '
   
   w3 = kerroin1*aika   ' kertolaskun 16 vähiten merkitsevää bittiä
   
   w2 = kerroin1**aika  ' kertolaskun 16 eniten merkitsevää bittiä
   
   w0 = kerroin0*aika  ' kertolaskun 16 vähiten merkitsevää bittiä
   
   w4 = kerroin0**aika ' kertolaskun 16 eniten merkitsevää bittiä
   
   
   w1 = w3 + w4
   
   
  
   
   ' Seuraavassa testataan onko voimassa w1 < w3 ja w1 < w4 ja jos on niin lisätään w2:n arvoa yhdellä.
   
   if w1 < w3 AND w1 < w4 then
   
      inc w2
   
   endif
   
   
   ' Nyt siis laskun 70466459*aika tulos saadaan muistipaikkojen w2, w1 ja w0 avulla muodossa
   ' w2*65536^2 + w1*65536^1 + w0*65536^0. w3, w4  ovat vapaasti käytettävissä jatkossa.
   
   ' Seuraavaksi pyritään lisäämään luku 1322745133 = vakio1*65536^1 + vakio0*65536^0 edellä lasketun kertolaskun
   ' tulokseen. Tämä vaihe on oikeastaan turha, mutta tehdään se sen vuoksi että tämä aliohjelma antaa saman tuloksen 
   ' kuin edellisen ohjelmaversion vastaava aliohjelma.
   ' Yhteenlasku saadaan esitettyä muodossa
   '
   ' 70466459*aika + 1322745133 = w2*65536^2 + w1*65536^1 + w0*65536^0 + vakio1*65536^1 + vakio0*65536^0
   '
   ' = w2*65536^2 + (w1 + vakio1)*65536^1 + (w0 + vakio0)*65536^0.
   '
   ' Tässä pitää taas muistaa ottaa huomioon myös tapaukset, jolloin w0 + vakio0 vuotaa yli 16-bittisestä muistipaikasta
   ' jne. Tallennetaan ensin laskun w0 + vakio0 tulos muistipaikkaan w3 ja toimitaan hieman samaan tapaan kuten 
   ' edellä kertolaskun yhteydessä:
   
   w3 = w0 + vakio0
   
    ' Seuraavassa testataan onko voimassa w3 < vakio0 ja w3 < w0 ja jos on niin asetetaan muistiNro:ksi 1(muutoin == 0).
   
   if w3 < vakio0 AND w3 < w0 then
   
       muistiNro = 1
   
   endif
   
   ' Sijoitetaan summa takaisin w0:aan, jonka jälkeen w3 on taas käytössä muuhun tarkoitukseen.
   ' w0 pitää siis tämän jälkeen sisällään laskun tuloksen "ensimmäisen numeron" 65536-kantaisessa järjestelmässä, ts.
   ' laskun lopputuloksen 16 vähiten merkitsevää bittiä.
  
  
   w0 = w3
   
   
   ' Lasketaan w3:aan seuraavaksi vakio1 + muistiNro. Tässä ei tule ylivuotoa kunhan vakio1 <= 65534
   
   w3 = vakio1 + muistiNro
   
   ' Lasketaan sitten w4:een w1 + vakio1 + muistiNro = w1 + w3. Tämän jälkeen w4 pitää sisällään laskun tuloksen
   ' "toisen numeron" 65536-kantaisessa järjestelmässä, ts. laskun lopputuloksen 16 keskimmäistä bittiä.
   '
   
   w4 = w1 + w3
   
   
   if w4 < w1 AND w4 < w3 then  ' Jos on tapahtunut ylivuoto laskussa w1 + w3 = w1 + vakio1 + muistiNro
                                ' muistetaan kasvattaa w2:sta 1:llä. w2 antaa siis laskun lopuutuloksen
       inc w2                   ' 16 eniten merkitsevää bittiä.
   
   endif
   
   'Sijoitetaan vielä keskimmäiset bitit w4:sta w1:een.
   
   w1 = w4
   
   ' Tämän jälkeen laskun 70466459*aika + 1322745133 lopputulos on muuttujissa w2, w1 ja w0 s.e. tulos saadaan
   ' laskemalla w2*65536^2 + w1*65536^1 + w0*65536^0. w3, w4 ja w5 ovat taas käytettävissä muuhun tarkoitukseen jatkossa.
   
   ' Nyt seuraavaksi haluttaisiin siis saada tämän laskun w2*65536^2 + w1*65536^1 + w0*65536^0 vastaus tutussa 10-
   ' kantaisessa lukujärjestelmässä. Miten se onnistuu? Idea on seuraava:
   ' Lasketaan ensin laskun tuloksen jakojäännös, kun tulos jaetaan sadalla. Jakojäännöksenä saadaan jokin luku s.e.
   ' 0 <=luku < 99. Huomaa että tämä luku antaa siis laskun w2*65536^2 + w1*65536^1 + w0*65536^0 tuloksen kaksi vähiten 
   ' merkitsevää numeroa 10-järjestelmässä. Vähennetään seuraavaksi w2*65536^2 + w1*65536^1 + w0*65536^0 - luku, 
   ' ja sijoitetaan vähennyslaskun tulos takaisin muistipaikkoihin w2, w1 ja w0 s.e. vähennyslaskun tulos saadaan 
   ' muodossa w2*65536^2 + w1*65536^1 + w0*65536^0. Nyt tiedetään, että tämän laskun tulos on sadalla jaollinen.
   ' Jaetaan nyt laskun tulos sadalla ja sijoitetaan jakolaskun tulos takaisin muistipaikkoihin w2, w1 ja w0 s.e.
   ' jakolaskun tulos saadaan lausekkeesta w2*65536^2 + w1*65536^1 + w0*65536^0. Jos lasketaan tämän luvun jakojäännös,
   ' kun se jaetaan sadalla, niin saadaan halutun vastauksen seuraavat kaksi numeroa. Näin jatketaan kunnes kaikki
   ' w2, ja w1 ja w0 ovat nollia. Tällöin on saatu kaikki vastauksen numerot 10- järjestelmässä kuten haluttiin.
   
   
   ' Huomaa, että tulon jakojäännös on aina yhtä suuri kuin tulon tekijöiden jakojäännösten tulon jakojäännös :)
   ' Vastaava tulos pätee summalle. Nyt 65536^2:n jakojäännös sadalla jaettaessa on 96 ja 65536:n jakojäännös sadalla
   ' jaettaessa on 36. Näitä käytetään jatkossa moneen kertaan.
   
   
   do
   
      ' Lasketaan ensin w0:n, w1:n ja w2:n jakojäännökset sadalla jaettaessa muuttujiin b6, b7 ja b8
   
      b6 = w0 % 100
   
      b7 = w1 % 100
   
      b8 = w2 % 100
   
      ' Lasketaan sitten aluksi w5:een koko lausekkeen w2*65536^2 + w1*65536^1 + w0*65536^0 jakojäännös sadalla jaettaessa:
   
   
      w5 = b8 * 96  
   
      w6 = b7 * 36
   
      w5 = w5 + w6
   
      w5 = w5 + b6
      
      w5 = w5 % 100
      
      ' Sijoitetaan vielä tulos muuttujaan b6, jolloin b7, b8 jne. vapautuvat jatkokäyttöön.
      
      b6 = w5 
      
      
     ' Pyritään sitten laskemaan vähennyslasku w2*65536^2 + w1*65536^1 + w0*65536^0 - b6. Jos w0 >= b6, niin lopputulos
     ' saadaan yksinkertaisesti suoraan vähentämällä w0 - b6. Jos puolestaan w0 < b6, niin on lainattava enemmän merkit-
     ' sevistä numeroista. Jos w1 >= 1, niin lainaus voidaan tehdä s.e. vähennetään w1:n arvoa yhdellä ja uusi w0 saadaan
     ' laskemalla 65536 + w0 - b6 = 65535 - b6 + w0 + 1 (Näin laskemalla vältytään ylivuodolta). Jos w1 == 0, niin lainaus 
     ' tehtävä w2:sta asti. Tällöin w2:sta pitää vähentää yhdellä ja asettaa w1 = 65535, ja laskea samaan tapaan kuin 
     ' edellä uusi w0 kaavasta 65536 + w0 - b6 = 65535 - b6 + w0 + 1. Huomataan kuitenkin että myös tapauksessa w1 == 0
     ' voidaan laskea w1 - 1, Ja tulos on 65535 kuten pitääkin. Lisäksi havaitaan, että myös tapauksessa w0 < b0
     ' voidaan uuden w0:n laskeminen hoitaa kaavalla w0 - b6(hallittu alivuoto). Nyt siis on pohdittu miten vähennyslasku 
     ' pitää suorittaa kaikissa mahdollisissa tapauksissa. Tämä idea on toteutettu alla:
      
     
      
     if w0 < b6 then
     
         if w1 = 0 then
     
            dec w2         'Tämä vähennys johtuu lainaamisesta
     
         endif
     
         dec w1         'Tämä vähennys johtuu lainaamisesta
     
     endif
     
     w0 = w0 - b6    ' Näin siis saadaan kaikissa tapauksissa oikea w0.
     
    
     ' Nyt w2, w1 ja w0 pitävät sisällään vähennyslaskun tuloksen s.e. tulos on w2*65536^2 + w1*65536^1 + w0*65536^0
     
     
     ' Tallennetaan lopputuloksen numerot muistiin paikasta 16 lähtien. Siis kaksi vähiten
     ' merkitsevää numeroa löytyy muistipaikasta 16, seuraavat 2 paikasta 17 jne.
     
     
     bptr = kierrokset + 16
     
     @bptr = b6         ' Tallennetaan numerot bptr:n osoittamaan muistipaikkaan, eli paikasta 16 alkaen.
     
     inc kierrokset
     
    
     ' Paikasta 16 lähtien on ainakin jonkin matkaa muistissa lopputuloksen numeroita.
     ' Lopputuloksen tallettamiseen tarvitaan korkeintaan 8 muistipaikkaa, kun kaksi
     ' numeroa on yhdessä muistipaikassa.
     
     ' Seuraavaksi pitäisi siis tehdä jakolasku (w2*65536^2 + w1*65536^1 + w0*65536^0)/100 
     ' Laskennassa voi käyttää apuna nyt esim. muistipaikkoja b6.....b15.
     '
     ' Jakokulman voisi kirjoittaa lyhyemmin silmukkarakenteen avulla, mutta se saataa
     ' hankaloittaa sen ymmärtämistä.
     '
     ' Havainnollistava kuva jakokulmasta:
     '
     '            b15b14....
     '            ____________
     '        100|b5b4b3b2b1b0
     '
     '            b7.
     '            .
     '
      
       
      b15 = b5/100     ' b15 pitää siis nyt sisällään jakolaskun tuloksen ensimmäisen "numeron"
     
      b7 = 100*b15     ' Kertolaskun tulos b7:aan
     
      b7 = b5 - b7     ' Vähennyslasku
      
      b6 = b4          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
   
     ' Nyt w3 = b7b6 pitää sisällään sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' toisen "numeron"
     
      b14 = w3/100    ' b14 pitää siis sisällään jakolaskun tuloksen toisen "numeron"
      
      w4 = 100*b14     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' Vähennyslasku
      
      b6 = b3          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pitää sisällään sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' kolmannen "numeron"
      
      b13 = w3/100    ' b13 pitää siis sisällään jakolaskun tuloksen kolmannen "numeron"
      
      w4 = 100*b13     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' Vähennyslasku
      
      b6 = b2          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pitää sisällään sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' neljännen "numeron"
      
      b12 = w3/100    ' b12 pitää siis sisällään jakolaskun tuloksen neljännen "numeron"
      
      w4 = 100*b12     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' Vähennyslasku
      
      b6 = b1          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pitää sisällään sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' viidennen "numeron"
      
      b11 = w3/100    ' b11 pitää siis sisällään jakolaskun tuloksen viidennen "numeron"
      
      w4 = 100*b11     ' Kertolaskun tulos w4:een
      
      b7 = w3 - w4     ' Vähennyslasku
      
      b6 = b0          ' Pudotetaan numero alas aivan kuten tavallisessakin jakokulmassa
      
      
     ' Nyt w3 = b7b6 pitää sisällään sen luvun joka sadalla jaettaessa antaa jakolaskun
     ' kuudennen eli viimeisen numeron "numeron"
      
      b10 = w3/100    ' b10 pitää siis sisällään jakolaskun tuloksen viimeisen "numeron"
      
     ' Sijoitetaan seuraavaksi nyt w7:ssa(=b15b14), w6:ssa(=b13b12) ja w5:ssa(=b11b10) oleva 
     ' jakolaskun lopputulos takaisin muuttujiin w2, w1 ja w0.
      
      w2 = w7
      
      w1 = w6
      
      w0 = w5
      
      ' Jos vielä vähintään yksi w2, w1 tai w0 on nollasta eroava, niin kaikkia 10-järjestelmän
      ' numeroita ei ole vielä etsitty. Jatketaan siis silmukkaa ja etsitään lisää numeroita.
      ' Jakokulma pyöräytetään oikeasataan turhaan yhden kerran viimeisellä kierroksella mutta
      ' eipa tuo haittaa.
      '
      
   loop until w2 = 0 AND w1 = 0 AND w0 = 0
   
   ' Nyt laskenta on valmis ja lopputulos on muistipaikoissa b16,b17,... s.e. vähiten merkitsevät kaksi numeroa ovat
   ' paikassa b16, seuraavat b17, jne.
   ' Montako muistipaikkaa numeroitten tallettamiseen on oikeastaan käytetty?
   ' Koska 70466459*aika + 1322745133 <= 70466459*65535 + 1322745133 == 4619342135698 ja kaksi numeroa on
   ' aina talletettuna yhteen muistipaikkaan, niin muistipaikkoja on käytetty 7. Siis lopullinen tulos saadaan
   ' 10-järjestelmässä suoraan s.e. tulos = b22b21b20b19b18b17b16. Sekunteina tulos saadaan tästä kun lisätään pilkku
   ' kahden eniten merkitsevän numeron väliin.
   
   for b23 = 0 to 6          'numeroitten erottaminen erillisiin muistipaikkoihin ennen lähetystä.
   
      bptr = 16 + b23        ' vähiten merkitsevä numero tulee siis b0:aan jne. Eniten merkitsevä b12:sta.
   
      b24 = @bptr
      
      bptr = b23 * 2
      
      @bptr = b24 % 10
      
      bptr = bptr + 1
      
      @bptr = b24/10
   
   next b23
   
   kierrokset = 0
   
   muistiNro = 0
   
   for b23 = 16 to 22 ' Nollataan vielä numeroitten sijoituspaikat, jotta ei tule jatkossa
                      ' vääriä lukemia
      bptr = b23 
                      
      @bptr = 0
   
   next b23
   
   
   ' Nyt lopputulos on muistipaikoissa b12,...,b0 s.e. vähiten merkitsevä numero on b0:ssa
   ' Sekunteina lopputulos saadaan kun lisätään pilkku b12 ja b11 väliin.
   
   ' Lähetetään seuraavassa tarkka aika tietokoneelle.
   
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