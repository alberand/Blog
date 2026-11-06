/*
 * Copy content of the element to the clipboard and show feedback on the button
 * Example:
 *	<button onclick="copy_to_clipboard(this, document.getElementById('code'))">copy</button>
 */
function copy_to_clipboard(button, element) {
	const REVERT_MS = 1500;

	function indicate(text, ok) {
		button.textContent = text;
		button.classList.toggle("copied", ok);
		if (button._copy_timer) {
			clearTimeout(button._copy_timer);
		}
		button._copy_timer = setTimeout(function () {
			button.textContent = "copy";
			button.classList.remove("copied");
		}, REVERT_MS);
	}

	function success() {
		indicate("copied", true);
	}

	function failure() {
		indicate("failed", false);
	}

	if (navigator.clipboard && navigator.clipboard.writeText) {
		navigator.clipboard.writeText(element.innerText).then(success, failure);
	} else {
		try {
			var range = document.createRange();
			range.selectNode(element);
			window.getSelection().removeAllRanges();
			window.getSelection().addRange(range);
			document.execCommand("copy") ? success() : failure();
			window.getSelection().removeAllRanges();
		} catch (err) {
			failure();
		}
	}
}
