function switchBillTab(to, title) {
    allTabs = Element.childElements('bill_tabs')
    allTabs.each(function(t) {
       Element.hide(t)
    });
    Element.show(to);
    $('popular_ul_title').innerHTML = title;

}