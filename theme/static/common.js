/*
 * Copy content of the element to the clipboard
 * Example:
 *	<div onclick="copy_to_clipboard(this)"> bla bla</div>
 */
function copy_to_clipboard(element) {
	var range = document.createRange();
	range.selectNode(element);
	window.getSelection().removeAllRanges();
	window.getSelection().addRange(range);
	document.execCommand("copy");
	window.getSelection().removeAllRanges();
}
