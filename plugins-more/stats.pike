inherit command;
inherit hook;
inherit statustext;

/* Keep stats on lines of text with numbers in them.

Provide an sscanf pattern for each, and the average will be maintained.

The monitors all have unique identifiers (mainly for the configdlg), and then have an sscanf
string. If that string has no non-star markers, the line will be retained, thus allowing
multi-line search patterns. Otherwise, it should have one %d (maybe %s could be added later?)
and that gets saved. Note that, in current code, a 0 result is assumed to mean continuation,
so a string like "foo bar %d asdf qwer" matching "foo bar 0 asdf qwer" will be misparsed.

As well as the sscanf pattern are two numbers: total and count. They effectively allow a
running average to be maintained.

TODO: Add a configdlg. (Data structures have been set up around that expectation.)
*/

mapping(string:mapping(string:mixed)) monitors=persist["stats/monitors"] || ([
	"raki_hold":(["sscanf":"You complete the process of disintegrating your flagon of raki and are"]),
	"raki":(["sscanf":"You complete the process of disintegrating your flagon of raki and are%*[ ]rewarded with %d handfuls of metal particles ready to be molded by"]),
]);

int outputhook(string line,mapping(string:mixed) conn)
{
	if (string last=m_delete(conn,"stats_laststr")) line=last+line; //Note, no separator. I might need to have that configurable.
	foreach (monitors;string kwd;mapping info) if (sscanf(line,info->sscanf,int value))
	{
		if (!value) {conn->stats_laststr=line; return 0;}
		if (!intp(value)) {say(conn->display,"%% Parse error: need an integer"); return 0;}
		info->total+=value; ++info->count;
		if (value>info->max) info->max=value;
		if (!has_index(info,"min") || value<info->min) info->min=value;
		persist["stats/monitors"]=monitors;
		setstatus(sprintf("%s: %d -> %.2f",kwd,value,info->total/(float)info->count));
	}
}

int process(string param,mapping(string:mixed) subw)
{
	foreach (monitors;string kwd;mapping info) if (info->count)
		say(subw,"%%%% %s: %d results %d-%d, averaging %.2f",kwd,info->count,info->min,info->max,info->total/(float)info->count);
	return 1;
}

void create(string name) {::create(name);}