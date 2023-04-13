import "relay/choice.ash";
import "relay/AutumnRelay.ash"
//Choice	override

void main(string page_text_encoded)
{
	string page_text = page_text_encoded.choiceOverrideDecodePageText();
	handleAutumnAton(page_text);
	
}