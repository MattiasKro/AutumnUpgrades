
Record AutumnDestinationGroup {
	int seq;
	string description;
	string difficulty;
	string locationType;
	boolean upgraded;
	location [int] destinations;
};
	
AutumnDestinationGroup createDestinationGroup(string difficulty, string locationType, string upgradeDescription, string upgrade, string page_text) {
	AutumnDestinationGroup optionGroup;
	if (upgradeDescription.length() > 0) {
		optionGroup.description = difficulty + " " + locationType + " (" + upgradeDescription + ")";	
	} else {
		optionGroup.description = "Other";
	}
	optionGroup.difficulty = difficulty;
	optionGroup.locationType = locationType;
	if (upgrade.length() > 0) {
		optionGroup.upgraded = page_text.contains_text(upgrade);
	} else {
		optionGroup.upgraded = false;
	}
	clear(optionGroup.destinations); 
	return optionGroup;
}

string getUpgradeDesctiption(AutumnDestinationGroup destination) {
	if ((!destination.upgraded) && (destination.description != "Other")) {
		return "*"+destination.description;
	}
	return destination.description;
}

string buildLocationTypeOption(AutumnDestinationGroup [int] destinationList) {
	buffer result;
	result.append("\t\t<select name=\"destinationtypepicker\"");
	result.append(" onchange=\"javascript:{var sel = this.value;var opts = document.getElementById('heythereprogrammer');");
	result.append("for (i = 0; i < opts.length; i++) {");
	result.append("var el = opts.options[i];if ((sel == 'all') || (el.getAttribute('data-zone') == sel)) {el.hidden = false;");
	result.append("} else { el.hidden = true; }}}\"");
	result.append(">\n");
	result.append("\t\t\t<option selected value=\"all\">All zone types</option>\n");
	foreach key, dest in destinationList {
		if (count(dest.destinations) >= 1) {
			string className = "zone-" + dest.difficulty + "-" + dest.locationType;
			if (dest.upgraded) {
				className += " upgraded";
			}
			result.append("\t\t\t\t<option value=\"zone-" + to_lower_case(dest.difficulty) + "-" + to_lower_case(dest.locationType) + "\">");
			result.append(getUpgradeDesctiption(dest) + "</option>\n");
		}
	}
	result.append("\t\t</select>\n");
	return result;
}

void handleAutumnAton(string page_text)
{
	AutumnDestinationGroup [int] groups;
	groups[1] = createDestinationGroup("High", "indoor", "'better' items", "radardish.png", page_text);
	groups[2] = createDestinationGroup("High", "outdoor", "'better' items", "periscope.png", page_text);
	groups[3] = createDestinationGroup("High", "underground", "+experience", "dualexhaust.png", page_text);
	groups[4] = createDestinationGroup("Mid", "indoor", "-11 expedition length", "rightleg1.png", page_text);
	groups[5] = createDestinationGroup("Mid", "outdoor", "+1 zone item", "rightarm1.png", page_text);
	groups[6] = createDestinationGroup("Mid", "underground", "+1 autumn item", "cowcatcher.png", page_text);
	groups[7] = createDestinationGroup("Low", "indoor", "+1 zone item", "leftarm1.png", page_text);
	groups[8] = createDestinationGroup("Low", "outdoor", "+experience", "base_blackhat.png", page_text);
	groups[9] = createDestinationGroup("Low", "underground", "-11 expedition length", "leftleg1.png", page_text);
	groups[10] = createDestinationGroup("other", "other", "", "", page_text);

	buffer newLocationPicker;

// Find all possible locations where we can send the autumn-aton
	matcher locmatcher = create_matcher("<option *?value\=\"(.*?)\">.*?</option>", page_text);
	while (find(locmatcher)) {
		if (group(locmatcher,1).length() > 0) {
			location loc = to_location(to_int(group(locmatcher,1)));
			boolean found = false;
			foreach key, destinationGroup in groups {
				if ((destinationGroup.difficulty ≈ loc.difficulty_level) && (destinationGroup.locationType ≈ loc.environment)) {
					destinationGroup.destinations[count(destinationGroup.destinations)] = loc;
					found = true;
				}
			}
			if (!found) {
					groups[10].destinations[count(groups[10].destinations)] = loc;
			}
			newLocationPicker.append("\t\t\t<option data-zone=\"zone-"+to_lower_case(loc.difficulty_level)+"-"+to_lower_case(loc.environment)+"\" value=\""+loc.id+"\">"+loc+"</option>\n");
		}
	}

// Build the new selector
	buffer extra_text;

	extra_text.append(buildLocationTypeOption(groups));
	extra_text.append("\t\t<select required id=\"heythereprogrammer\" name=\"heythereprogrammer\">\n");
	extra_text.append("\t\t\t<option selected disabled value=\"\">-- select a location --</option>\n");
	extra_text.append(newLocationPicker);
	extra_text.append("\t\t</select>\n");

// Replace the old selector with the new
	string new_page_text = page_text.replace_string("</select>", "</select> -->");
	new_page_text = new_page_text.replace_string("<select required", extra_text + " <!-- <select required");
	
	write(new_page_text);
}

