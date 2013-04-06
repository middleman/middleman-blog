/*
=require vendor/zepto
=require foundation/foundation
=require foundation/foundation.section
=require foundation/foundation.tooltips
=require foundation/foundation.topbar
=require _zepto.pjax
*/

$(document).foundation();
$(document).pjax('a', '#container', { fragment: '#container' });