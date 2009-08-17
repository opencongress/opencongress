window.addEvent('domready', function() {
  //create our Accordion instance
  var efekt = new Accordion('div.header', 'div.elements', {
    opacity: false,
    display: 0,
    onActive: function(toggler, element){
      new Fx.Tween(toggler).start('background-color', '#EFEFEF');

    },
    onBackground: function(toggler, element){
      new Fx.Tween(toggler).start('background-color', '#BBB');
    }
  });
});
