declare default element namespace "http://www.tei-c.org/ns/1.0";
let $p5-chapters := collection('p5-chapters/en-2025-06-17/?select=*.xml')
let $p5-subset := doc('p5subset.xml')
let $p5 := doc('p5.xml')

let $specGrps := $p5//specGrp
let $specGrpParents := $specGrps/parent::*
let $specials := $p5//specList/parent::item/parent::list/parent::* ! name() => distinct-values()
return $specGrpParents ! name() => distinct-values()

