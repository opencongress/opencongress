function switchBillTab(to) {
    allTabs = Element.childElements('bill_tabs')
    allTabs.each(function(t) {
       Element.hide(t)
    });
    Element.show(to);
//    Element.addClassName(to + 'link','here');

}