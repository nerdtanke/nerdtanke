var Starfield = {

  x: 100,

  frame: function() {
    //alert('transparent url(../images/stars/ff.png) no-repeat ' + this.x + '% 1%');
    var stars = [];

    for (var y = 1; y < 100; y++) {
      stars.push('url(../images/stars/ff.png) no-repeat ' + this.x + '% ' + y + '%');
    }

    // alert(stars.join(', '));

    // $(document.body).css('background', 'url(../images/stars/ff.png) no-repeat ' + this.x + '% 1%');
    $(document.body).css('background', stars.join(', '));
    $('#debug').text('url(../images/stars/ff.png) no-repeat ' + this.x + '% 1%' == stars.join(', '));

    // $(document.body).css('background-image', 'url(../images/stars/ff.png), url(../images/stars/ff.png)');
    //$(document.body).css('background-position', + this.x + '% 1%, background-position' + this.x + '% 2%');
    //$(document.body).css('background-repeat', 'no-repeat');
    this.x -= 1;
    if (this.x < 0) {
      this.x = 100;
    }
  }

};


$(function() {
    setInterval(function() { Starfield.frame(); }, 50);
});
