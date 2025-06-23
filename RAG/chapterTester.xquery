declare default element namespace "http://www.tei-c.org/ns/1.0";
let $p5-chapters := collection('p5-chapters/en-2025-06-17/?select=*.xml')
let $p5-subset := doc('p5subset.xml')

let $specLists := $p5-chapters//specList
let $specListParents := $specLists/parent::*
let $itemWithSpecList := $p5-chapters//item[specList]
let $itemGrandparent := $itemWithSpecList/../.. ! name() => distinct-values()
let $pKids := $p5-chapters//p//* ! local-name() => distinct-values() => sort()
(:let $listTypeSL := $p5-chapters//*[local-name() ! starts-with(., 'spec')] ! name() => distinct-values()
 for $l in $listTypeSL 
let $lcount := $p5-chapters//*[local-name() = $l] => count()
return ($l||': Count in Guidelines: '||$lcount||'&#10;')  :)
(: let $specGrp := $p5-subset//*[local-name() = 'specGrp']
return $specGrp/ancestor::elementSpec :) 
(: for $k in $pKids
return ($k||'&#10;') :)
(: xxclassCodexx (used in examples), xxclassDeclxx, classRef, classSpec (all 4 @module='tei' are defined in TD tagdocs chapter:)

return $p5-chapters//*[local-name()='specGrpRef'] 


