$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Set-Property($Object,[string]$Name,$Value) {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
}

$stageA = @(Get-Content -Raw (Join-Path $root 'eval/gate1_cases.json') | ConvertFrom-Json)
foreach ($case in $stageA) {
    Set-Property $case 'retry_source' 'existing Gate 1 held-out case; revised representation only'
    switch ($case.id) {
        'gate-01' { Set-Property $case 'event_state' ([ordered]@{street_door='shut'; door_bell='rang once'}) }
        'gate-02' { $case.facts=@('river water has pooled across the threshold'); Set-Property $case 'post_action_state' ([ordered]@{office_door='open'; threshold='flooded'}) }
        'gate-03' { Set-Property $case 'post_action_state' ([ordered]@{hem_trace='pale clay'; inner_pocket='cut away'}) }
        'gate-04' { Set-Property $case 'post_action_state' ([ordered]@{final_cargo_line='absent from manifest'; remaining_ink='fresh blue'}) }
        'gate-05' { Set-Property $case 'post_action_state' ([ordered]@{filing_drawer='open'; drawer_handle='broken off'}); Set-Property $case 'event_state' ([ordered]@{caretaker_lantern='visible beneath corridor door'}) }
        'gate-06' { Set-Property $case 'post_action_state' ([ordered]@{brass_tag_access='obtained'; flowerpot='broken'}); Set-Property $case 'event_state' ([ordered]@{outside_voices='became quiet'}) }
        'gate-07' { Set-Property $case 'post_action_state' ([ordered]@{wall_safe='open'; safe_contents='empty velvet tray'}); Set-Property $case 'event_state' ([ordered]@{safe_bell='ringing'}) }
        'gate-08' { $case.facts=@('one walkway board splits','the bell rope swings within reach'); Set-Property $case 'post_action_state' ([ordered]@{Armand_location='near platform'; far_platform_access='unavailable'}) }
        'gate-09' { $case.facts=@('the pick snaps inside the keyhole','water begins dripping through the ceiling'); Set-Property $case 'post_action_state' ([ordered]@{iron_cabinet='locked'; cabinet_contents_access='unavailable'}) }
        'gate-10' { Set-Property $case 'post_action_state' ([ordered]@{locker_contents='empty'; locker_door='fallen against signal lever'}); Set-Property $case 'event_state' ([ordered]@{warning_bell='ringing'}) }
        'gate-11' { $case.facts=@('Guillermo feels a draft behind the tapestry'); Set-Property $case 'post_action_state' ([ordered]@{draft_source='behind tapestry'; concealed_area_visibility='unavailable'}) }
        'gate-12' { $case.facts=@('Guillermo smells something on the green valise'); Set-Property $case 'post_action_state' ([ordered]@{scent_source='unknown'; scent_meaning='unknown'}) }
        'gate-13' { $case.facts=@('Guillermo saw one person waiting beyond the curtain'); Set-Property $case 'post_action_state' ([ordered]@{person_count='one'; person_identity='unknown'}); Set-Property $case 'event_state' ([ordered]@{other_people_heard='none'}) }
        'gate-14' { $case.facts=@('the basket contains clean sheets and one wooden clothes peg'); Set-Property $case 'post_action_state' ([ordered]@{basket_contents='clean sheets and one wooden clothes peg'; consequential_evidence='none'}) }
        'gate-15' { $case.facts=@('the stand contains three dry umbrellas and street grit'); Set-Property $case 'post_action_state' ([ordered]@{umbrella_count='three'; umbrellas='dry'; street_grit='present in stand'; consequential_evidence='none'}) }
        'gate-16' { $case.facts=@('Armand asks when the patient arrived'); $case.PSObject.Properties.Remove('npc_disclosure'); Set-Property $case 'npc_discloses' @('two constables brought the patient shortly after one oclock','the patient was unconscious'); Set-Property $case 'npc_withholds' @('the ward where the patient was taken') }
        'gate-17' { $case.facts=@('Armand asks where the damaged crate arrived from'); $case.PSObject.Properties.Remove('npc_disclosure'); Set-Property $case 'npc_discloses' @('the crate came off the morning packet'); Set-Property $case 'npc_withholds' @('the consignee identity'); Set-Property $case 'event_state' ([ordered]@{inspector_response='asks to see Armand authority'}) }
        'gate-18' { $case.facts=@('Armand asks when the violinist left'); $case.PSObject.Properties.Remove('npc_disclosure'); Set-Property $case 'npc_discloses' @('the violinist left before the final curtain','the violinist carried no instrument case','the doorman did not see her direction'); Set-Property $case 'npc_withholds' @() }
        'gate-19' { $case.facts=@('the proof sheets are on the floor'); Set-Property $case 'post_action_state' ([ordered]@{desk_lamp='extinguished'; window='open'; proof_sheets='on floor'}); Set-Property $case 'recent_history' @('previous desk lamp state: lit','previous window state: closed','previous proof sheets location: floor') }
        'gate-20' { $case.facts=@('the chair is beneath the high window'); Set-Property $case 'post_action_state' ([ordered]@{account_book_access='unavailable'; account_book_location='absent from desk'; chair_location='beneath high window'; door='locked'}); Set-Property $case 'recent_history' @('previous account book location: open on desk','previous chair location: beside desk') }
    }
}
$stageA | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $root 'eval/grounding_retry_stageA_cases.json')

function New-Case([string]$id,[string]$category,[int]$seed,[string]$location,[string]$actor,[string]$action,[string]$target,[string]$degree,[string[]]$facts,[string[]]$visible,[hashtable]$state,[hashtable]$events,[string[]]$discloses,[string[]]$withholds,[string]$gesture='') {
    $o=[ordered]@{id=$id;category=$category;seed=$seed;location=$location;time='late night';weather='rain';actor=$actor;action_type=$action;target=$target;degree=$degree;facts=$facts;visible=$visible;forbidden_terms=@('murder','culprit','secret society')}
    if($state){$o.post_action_state=$state};if($events){$o.event_state=$events};if($discloses){$o.npc_discloses=$discloses};if($null-ne$withholds){$o.npc_withholds=$withholds};if($gesture){$o.guillermo_stage_direction=$gesture}
    [pscustomobject]$o
}
$stageB=@(
 New-Case 'confirm-01' 'failed_action_unchanged_state' 6201 'chemist storeroom' Armand 'unlocks' 'blue cabinet' failure @('the pick bends') @('blue cabinet','gas lamp','packing bench') @{cabinet='locked';contents_access='unavailable'} @{} @() @()
 New-Case 'confirm-02' 'failed_action_unchanged_state' 6202 'magistrate robing room' Armand 'opens' 'sealed dispatch case' failure @('the latch resists the key') @('dispatch case','robe hooks','mirror') @{dispatch_case='closed';seal='intact';contents_access='unavailable'} @{} @() @()
 New-Case 'confirm-03' 'failed_action_unchanged_state' 6203 'observatory archive' Armand 'retrieves' 'star ledger' failure @('dust falls from the shelf') @('high shelf','rolling ladder','desk') @{ledger_location='high shelf';ledger_access='unavailable'} @{} @() @()
 New-Case 'confirm-04' 'partial_success_limited_access' 6204 'undertaker office' Armand 'searches' 'locked escritoire' setback @('a receipt is found beneath the escritoire') @('escritoire','receipt','mourning drape') @{receipt_access='obtained';escritoire='locked';contents_access='unavailable'} @{} @() @()
 New-Case 'confirm-05' 'partial_success_limited_access' 6205 'telegraph depot' Armand 'examines' 'jammed message drawer' setback @('one torn message corner protrudes') @('message drawer','telegraph key','wall clock') @{message_fragment_access='obtained';drawer='jammed';remaining_messages_access='unavailable'} @{} @() @()
 New-Case 'confirm-06' 'setback_event_occurs' 6206 'river customs loft' Armand 'lifts' 'canvas tarpaulin' setback @('a brass seal lies beneath it') @('tarpaulin','brass seal','loft stairs') @{brass_seal_access='obtained'} @{loft_bell='rang once'} @() @()
 New-Case 'confirm-07' 'setback_event_occurs' 6207 'printer cellar' Armand 'moves' 'paper bale' setback @('the bale shifts aside') @('paper bale','ink barrels','cellar door') @{paper_bale='moved aside'} @{glass_bottle='fell and shattered';upstairs_footsteps='approaching'} @() @()
 New-Case 'confirm-08' 'bounded_npc_disclosure' 6208 'cab rank shelter' Armand 'asks' 'dispatcher about cab seventeen' success @('Armand asks when cab seventeen returned and who rode in it') @('dispatch board','bench','street door') @{} @{} @('cab seventeen returned at one oclock') @('the passenger identity')
 New-Case 'confirm-09' 'bounded_npc_disclosure' 6209 'museum porter desk' Armand 'asks' 'porter about the east door' success @('Armand asks when the east door opened and who used it') @('porter desk','key board','east corridor') @{} @{} @('the east door opened shortly before midnight') @('the person who used the door')
 New-Case 'confirm-10' 'bounded_npc_disclosure' 6210 'market watch house' Armand 'asks' 'sergeant about a detained cart' success @('Armand asks where the cart was stopped and what it carried') @('duty desk','wall map','cell door') @{} @{} @('the cart was stopped on Bell Street') @('the cart cargo')
 New-Case 'confirm-11' 'guillermo_gesture' 6211 'clock repair shop' Guillermo 'reacts to' 'warm air under the counter' resolved @('warm air rises beneath the counter') @('glass counter','clock parts','floor grate') @{warm_air_source='beneath counter'} @{} @() @() 'Guillermo crouches, tests the warm air with one hand, then points beneath the counter and looks to Armand without speaking.'
 New-Case 'confirm-12' 'guillermo_gesture' 6212 'theatre wardrobe' Guillermo 'reacts to' 'powder on a coat cuff' resolved @('white powder marks the coat cuff') @('dark coat','costume rail','mirror') @{powder_location='coat cuff';powder_identity='unknown'} @{} @() @() 'Guillermo sniffs the cuff, sneezes, wipes his nose with offended dignity, and points at the powder without speaking.'
 New-Case 'confirm-13' 'spell_result' 6213 'chapel vestry' Armand 'casts Detect Magic on' 'silver reliquary' success @('magic is present') @('silver reliquary','prayer stool','cold brazier') @{reliquary='closed';magic_presence='detected';magic_nature='unknown'} @{} @() @()
 New-Case 'confirm-14' 'spell_result' 6214 'flooded tunnel' Armand 'casts Light toward' 'far arch' failure @('the spell produces a brief spark') @('black water','far arch','brick ledge') @{far_arch_visibility='unavailable';light_source='extinguished'} @{} @() @()
 New-Case 'confirm-15' 'successful_investigation' 6215 'insurance assessor office' Armand 'investigates' 'burned account page' success @('three figures remain legible','the lower corner bears red sealing wax') @('burned page','adding machine','metal tray') @{legible_figures='three';red_wax_location='lower corner'} @{} @() @()
 New-Case 'confirm-16' 'successful_investigation' 6216 'canal toll booth' Armand 'investigates' 'muddy token' success @('the token bears the number forty-two','one edge is freshly filed') @('muddy token','cash drawer','canal window') @{token_number='42';token_edge='freshly filed'} @{} @() @()
 New-Case 'confirm-17' 'mundane_observation' 6217 'hotel scullery' Armand 'searches' 'coal bucket' success @('the bucket contains coal dust and a bent scoop') @('coal bucket','stone sink','service bell') @{consequential_evidence='none';bucket_contents='coal dust and bent scoop'} @{} @() @()
 New-Case 'confirm-18' 'mundane_observation' 6218 'station parcel room' Armand 'examines' 'empty wicker hamper' success @('the hamper contains only straw') @('wicker hamper','parcel scale','wire shelves') @{consequential_evidence='none';hamper_contents='straw'} @{} @() @()
 New-Case 'confirm-19' 'event_occurs' 6219 'boarding-house landing' Armand 'tests' 'loose banister' setback @('the banister shifts under pressure') @('loose banister','stair runner','numbered doors') @{banister='loose'} @{door_three='opened';unidentified_person_visibility='unavailable'} @() @()
 New-Case 'confirm-20' 'object_inaccessible' 6220 'harbour signal room' Armand 'reaches for' 'codebook behind glass' failure @('the cabinet key does not turn') @('glass cabinet','codebook','signal levers') @{glass_cabinet='locked';codebook_access='unavailable'} @{} @() @()
)
$stageB | ConvertTo-Json -Depth 12 | Set-Content -Encoding utf8 (Join-Path $root 'eval/grounding_retry_stageB_cases.json')
Write-Host 'Generated distinct 20-case Stage A and Stage B sets.'
