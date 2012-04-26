$(document).ready(function(){
	$(".ot").click(function(){
		$(".ot span").addClass("a");
		$(".mt span").removeClass("a");
		$("#typem").hide();
		$("#typeo").show();
		
		$("a.one").show();
		$("a.rec").hide();
	});
	
	$(".mt").click(function(){
		$(".mt span").addClass("a");
		$(".ot span").removeClass("a");
		$("#typeo").hide();
		$("#typem").show();
		
		$("a.one").hide();
		$("a.rec").show();
	});
});
