class DiseaseInfo {
  final String key;
  final Map<String, String> names;
  final Map<String, String> symptoms;
  final Map<String, String> causes;
  final Map<String, String> organicCare;
  final Map<String, String> chemicalTreatment;
  final Map<String, String> prevention;
  final String severity;

  const DiseaseInfo({
    required this.key,
    required this.names,
    required this.symptoms,
    required this.causes,
    required this.organicCare,
    required this.chemicalTreatment,
    required this.prevention,
    required this.severity,
  });

  String getName(String lang) => names[lang] ?? names['am'] ?? key;
  String getSymptoms(String lang) => symptoms[lang] ?? symptoms['am'] ?? '';
  String getCauses(String lang) => causes[lang] ?? causes['am'] ?? '';
  String getOrganicCare(String lang) => organicCare[lang] ?? organicCare['am'] ?? '';
  String getChemicalTreatment(String lang) => chemicalTreatment[lang] ?? chemicalTreatment['am'] ?? '';
  String getPrevention(String lang) => prevention[lang] ?? prevention['am'] ?? '';
}

class CoffeeDiseaseDatabase {
  static final Map<String, DiseaseInfo> diseases = {
    'Healthy': const DiseaseInfo(
      key: 'Healthy',
      severity: 'none',
      names: {
        'am': 'ጤናማ ቅጠል (ምንም በሽታ የለም)',
        'om': 'Baala Fayyaa (Dhukkuba hin qabu)',
        'en': 'Healthy Leaf (No Disease)',
      },
      symptoms: {
        'am': 'ቅጠሉ ጥቁር አረንጓዴ፣ የሚያብረቀርቅ እና ያለምንም ነጠብጣብ ወይም ጉዳት ያለ ነው።',
        'om': 'Baalli magariisa dukkanaawaa, kan ifuufi mallattoo miidhaa tokkollee kan hin qabne dha.',
        'en': 'Leaf is vibrant deep green, glossy, with no spots, lesions, or yellowing.',
      },
      causes: {
        'am': 'ተክሉ በቂ የተመጣጠነ ምግብ፣ ውሃ እና ተስማሚ ጥላ አግኝቷል።',
        'om': 'Biqiltuun nyaata madaalawaa, bishaan fi gaaddisa ga’aa argateera.',
        'en': 'The coffee tree receives optimal nutrition, moisture, and appropriate shade cover.',
      },
      organicCare: {
        'am': 'የማዳበሪያ ኮምፖስት አጠቃቀምን መቀጠል፤ በደረቅ ወቅት የኮሶ/ቅጠል ማልች (Mulch) ማድረግ።',
        'om': 'Koompostii itti fufinsaan fayyadamuu; yeroo gogaa baalaan biyyoosa uwwisuu (mulching).',
        'en': 'Maintain organic composting and apply dry mulch around the base during dry periods.',
      },
      chemicalTreatment: {
        'am': 'ምንም ዓይነት ኬሚካል አያስፈልገውም።',
        'om': 'Qoricha keemikaalaa tokkollee hin barbaadu.',
        'en': 'No chemical treatment needed.',
      },
      prevention: {
        'am': 'አሮጌ እና የደረቁ ቅርንጫፎችን በየወቅቱ መግረዝ እና አረም በወቅቱ ማረም።',
        'om': 'Daree dullomaafi gogaa yeroo yeroon baasuu fi aramaa yeroon aramuu.',
        'en': 'Regular pruning of old non-productive branches and timely weed management.',
      },
    ),

    'Leaf rust': const DiseaseInfo(
      key: 'Leaf rust',
      severity: 'high',
      names: {
        'am': 'የቡና ቅጠል ዝገት በሽታ (Rust)',
        'om': 'Dhukkuba Waaqoo Baala Bunaa (Leaf Rust)',
        'en': 'Coffee Leaf Rust (Hemileia vastatrix)',
      },
      symptoms: {
        'am': 'በቅጠሉ ስር ቢጫ ወይም ብርቱካናማ የዱቄት መልክ ያላቸው ነጠብጣቦች ይታያሉ፤ ቅጠሉ በፍጥነት ይረግፋል።',
        'om': 'Jala baalaatti kukkullaa keelloo ykn burtukaana dhumuutu mul’ata; baalli ni harca’a.',
        'en': 'Yellowish-orange powdery spore patches on leaf undersides, leading to premature defoliation.',
      },
      causes: {
        'am': 'ሄሚሊያ ቫስታትሪክስ (Hemileia vastatrix) ፈንገስ፤ በዝናብ ጠብታ እና ከፍተኛ እርጥበት ይስፋፋል።',
        'om': 'Fangaasii Hemileia vastatrix; dhangala’aa bokkaafi jiidhina guddaan babal’ata.',
        'en': 'Fungus Hemileia vastatrix, dispersed rapidly through rain splashes, high humidity, and wind.',
      },
      organicCare: {
        'am': 'አየር እና የፀሐይ ብርሃን በደንብ እንዲገባ ዛፎችን መግረዝ፤ በበሽታው የተጠቁትን ቅጠሎች ሰብስቦ ማቃጠል። ዝገት መቋቋም የሚችሉ ዝርያዎችን (ለምሳሌ 74110፣ 74112) መትከል።',
        'om': 'Qilleensiifi aduun akka galuuf dameewwan madaallii eeguun ciruu; baala miidhame gubuudha.',
        'en': 'Prune trees to improve ventilation and sun penetration. Collect and destroy dropped infected leaves. Plant rust-resistant cultivars (e.g. 74110, 74112).',
      },
      chemicalTreatment: {
        'am': 'የመዳብ ፀረ-ፈንገስ (Copper Oxychloride 50% WP) በ 1 ሄክታር ከ 3-4 ኪ.ግ ወይም Bayleton (Triadimefon) ዝናብ ከመግባቱ በፊት መርጨት።',
        'om': 'Qoricha koopparii (Copper Oxychloride) ykn Bayleton bokkaan eegaluun dura biifuu.',
        'en': 'Spray Copper Oxychloride 50% WP (3-4 kg/ha) or systemic Triadimefon (Bayleton) before rainy season.',
      },
      prevention: {
        'am': 'ጥላ ዛፎችን ሚዛናዊ ማድረግ (ከ 40-50% ጥላ) እና ተክሉን በፖታሽ ማዳበሪያ ማጠናከር።',
        'om': 'Gaaddisa madaalawaa eeguufi biqiltuun albuuda Pootaashiyemii ga’aa akka argatu gochuu.',
        'en': 'Maintain balanced shade canopy (40-50%) and provide adequate potassium nutrition.',
      },
    ),

    'Cerscospora': const DiseaseInfo(
      key: 'Cerscospora',
      severity: 'medium',
      names: {
        'am': 'ሰርኮስፖራ / የቡናማ አይን በሽታ (Brown Eye)',
        'om': 'Dhukkuba Ija Boora Baala Bunaa (Cercospora)',
        'en': 'Brown Eye Spot (Cercospora coffeicola)',
      },
      symptoms: {
        'am': 'መሃላቸው አመድማ / ነጭ የሆኑ፣ ዙሪያቸው በቢጫ ቀለበት የታጠሩ ክብ ቡናማ ነጠብጣቦች በቅጠሉ ላይ ይታያሉ።',
        'om': 'Mallattoo bifa booraa jidduunsaa daalacha ta’ee naannoon isaa keelloo qabu baalarraatti uuma.',
        'en': 'Small brown circular spots with grayish-white centers surrounded by a distinct chlorotic yellow halo.',
      },
      causes: {
        'am': 'የናይትሮጅን ማዳበሪያ እጥረት፣ ተክሉ በፀሐይ በቀጥታ መመታት እና የአፈር ድህነት።',
        'om': 'Hanqina albuuda Naayitiroojiinii, aduun daran gubuu fi biyyoofi gabbina dhabuu.',
        'en': 'Nitrogen deficiency, soil nutrient depletion, and excessive exposure to direct harsh sunlight.',
      },
      organicCare: {
        'am': 'የጥላ ዛፎችን (እንደ ዋንዛ፣ ብርብራ) በቡና ማሳው ውስጥ ማብዛት፤ የናይትሮጅን ይዘት ያለው የተቦካ ማዳበሪያ መጨመር።',
        'om': 'Muka gaaddisaa (kan akka Waanzaa) dabaluu; koompostii naayitiroojiiniin badhaadhe kennuu.',
        'en': 'Establish native shade trees (e.g. Cordia africana / Wanza); apply compost rich in nitrogen.',
      },
      chemicalTreatment: {
        'am': 'መዳብ ነክ ፀረ-ፈንገስ (Copper Hydroxide) ወይም ማንኮዜብ (Mancozeb 80% WP) መርጨት።',
        'om': 'Qoricha koopparii ykn Maankoozebii (Mancozeb 80% WP) biifuu.',
        'en': 'Apply protective copper fungicide or Mancozeb 80% WP (2-2.5 kg/ha).',
      },
      prevention: {
        'am': 'የቡና ችግኞች በመዋዕለ-ህፃናት (nursery) እያሉ በቂ ጥላ እና የተመጣጠነ ማዳበሪያ እንዲያገኙ ማድረግ።',
        'om': 'Biqiltuu daa’imaa irratti gaaddisaafi nyaata sirrii kennuun eeguu.',
        'en': 'Ensure seedlings in nurseries and young plantations receive sufficient mulch and shade.',
      },
    ),

    'Miner': const DiseaseInfo(
      key: 'Miner',
      severity: 'medium',
      names: {
        'am': 'የቡና ቅጠል ቆፋሪ ትል (Leaf Miner)',
        'om': 'Bilaacha Baala Qotu (Coffee Leaf Miner)',
        'en': 'Coffee Leaf Miner (Leucoptera coffeella)',
      },
      symptoms: {
        'am': 'በቅጠሉ ውስጣዊ ክፍል ነጭ/ብርማ ጠመዝማዛ ዋሻዎች እና የደረቁ ቡናማ ሰፋፊ መስመሮች ይታያሉ።',
        'om': 'Kallattii baalaa keessatti boolla adii/daalacha fi sarara gogaa booraa uuma.',
        'en': 'Irregular serpentine blotches and silvery-white translucent mines/tunnels inside the leaf tissue.',
      },
      causes: {
        'am': 'ትንሽ ነጭ የእሳት እራት (Moth) እንቁላል በቅጠሉ ላይ ስትጥል የሚፈለፈሉት ትሎች ቅጠሉን ውስጡን ይቦረቡራሉ።',
        'om': 'Bilaacha adii baala irratti hanqaaquu buustu; ilbiisni dhalatu baala keessa nyaata.',
        'en': 'Larvae of the tiny Leucoptera moth burrowing into and feeding on internal leaf mesophyll.',
      },
      organicCare: {
        'am': 'በሽታው ገና ሲጀምር የተጎዱትን ቅጠሎች በእጅ ቆርጦ ማቃጠል፤ የተፈጥሮ ጠላቶቻቸውን (የተባይ አዳኝ ተርቦችን) አለማጥፋት። የኒም (Neem) ዛፍ ቅጠል ውሃ ርጭት።',
        'om': 'Baala jalqaba irratti miidhame harkaani ciranii gubuu; qoricha uumamaa Neemi fayyadamuu.',
        'en': 'Hand-pick and burn mined leaves in early stages; spray biological neem extract; preserve predatory wasps.',
      },
      chemicalTreatment: {
        'am': 'ጉዳቱ ከ 25% በላይ ከደረሰ ስልታዊ ፀረ-ተባይ (Systemic Insecticide እንደ Chlorpyrifos ወይም Dimethoate) መርጨት።',
        'om': 'Yoo miidhaan 25% ol ta’e qoricha ilbiisaa (Dimethoate ykn Chlorpyrifos) biifuu.',
        'en': 'If infestation exceeds 25-30% of canopy, apply systemic insecticide (e.g. Chlorpyrifos or Cartap).',
      },
      prevention: {
        'am': 'ከመጠን ያለፈ የፀሐይ ሙቀትን በዛፍ ጥላ መከላከል፤ ተፈጥሯዊ የነፍሳት ሚዛንን መጠበቅ።',
        'om': 'Ho’a aduu cimaa ittisuuf gaaddisa uumuu; madaallii uumamaa eeguu.',
        'en': 'Reduce drought stress with proper shade management and avoid broad-spectrum insecticide overuse.',
      },
    ),

    'Phoma': const DiseaseInfo(
      key: 'Phoma',
      severity: 'high',
      names: {
        'am': 'ፎማ / የቅጠል ጫፍ መድረቅ በሽታ (Phoma Dieback)',
        'om': 'Dhukkuba Fomaa / Qarqara Baalaa Gorsu (Phoma)',
        'en': 'Phoma Leaf Spot & Dieback (Phoma costaricensis)',
      },
      symptoms: {
        'am': 'ከቅጠሉ ጫፍ እና ጠርዝ የሚጀምር ጠቆር ያለ ጥቁር-ቡናማ መድረቅ፤ ቅጠሎቹ ተጠቅልለው ይደርቃሉ።',
        'om': 'Qarqaraafi fiixee baalaarraa kan eegalu gogiinsa gurraacha-booraa; baalli ni marama.',
        'en': 'Dark brown to black necrotic lesions expanding from leaf margins and tips, curling and drying the foliage.',
      },
      causes: {
        'am': 'ፎማ (Phoma) ፈንገስ፤ በከፍተኛ ንፋስ፣ በከፍተኛ ቦታዎች ቅዝቃዜ (Frost) እና በበረዶ ቁስለት ይመጣል።',
        'om': 'Fangaasii Phoma; qilleensa cimaa, qorra gaaraafi cabbii booda madaa irratti uumama.',
        'en': 'Phoma costaricensis fungus, triggered by strong cold winds, high elevation chill, and hail damage.',
      },
      organicCare: {
        'am': 'በማሳው ዙሪያ የንፋስ መከላከያ ረዣዥም ዛፎችን መትከል፤ የተጎዱትን ቅርንጫፎች ቆርጦ ማውጣት።',
        'om': 'Naannoo lafa bunaatti mukkeen qilleensa ittisan dhaabuu; damee goge kutee balleessuu.',
        'en': 'Establish windbreak tree hedges around the plantation; prune diseased twigs 5 cm below damage.',
      },
      chemicalTreatment: {
        'am': 'የመዳብ ፀረ-ፈንገስ (Copper Hydroxide) ወይም በዝናባማ ወራት በየ 21 ቀኑ መከላከያ ርጭት ማድረግ።',
        'om': 'Qoricha koopparii (Copper Hydroxide) guyyaa 21 21n biifuu.',
        'en': 'Spray protective Copper Hydroxide or Captan, especially after severe cold wind/rain events.',
      },
      prevention: {
        'am': 'ንፋስ በሚበዛባቸው ኮረብታማ ቦታዎች ላይ ቡናን ያለ ንፋስ ከልካይ ዛፎች አለመትከል።',
        'om': 'Bakka qilleensi jabaa jirutti muka ittisa malee buna dhaabuu dhiisuu.',
        'en': 'Never cultivate coffee on exposed high-altitude windward slopes without dense windbreak barriers.',
      },
    ),
  };

  static DiseaseInfo get(String key) {
    return diseases[key] ?? diseases['Healthy']!;
  }
}
