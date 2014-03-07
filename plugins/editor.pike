inherit hook;

class editor(mapping(string:mixed) conn)
{
	inherit movablewindow;
	constant pos_key="editor/winpos";
	constant load_size=1;

	void create(string initial)
	{
		win->initial=initial;
		::create(); //No name. Each one should be independent.
		win->mainwindow->set_skip_taskbar_hint(0)->set_skip_pager_hint(0); //Undo the hinting done by default
	}

	void makewindow()
	{
		win->mainwindow=GTK2.Window((["title":"Pop-Out Editor","type":GTK2.WINDOW_TOPLEVEL]))->add(GTK2.Vbox(0,0)
			->add(GTK2.ScrolledWindow()
				->add(win->mle=GTK2.TextView(win->buf=GTK2.TextBuffer()->set_text(win->initial)))
			)
			->pack_end(GTK2.HbuttonBox()
				->add(win->pb_send=GTK2.Button((["label":"_Send","use-underline":1,"focus-on-click":0])))
				->add(GTK2.Frame("Cursor")->add(win->curpos=GTK2.Label("")))
				->add(win->pb_close=GTK2.Button((["label":"_Close","use-underline":1,"focus-on-click":0])))
			,0,0,0)
		);
		win->mle->modify_font(G->G->window->getfont("input"));
		win->buf->set_modified(0);
		::makewindow();
	}

	void pb_send_click()
	{
		send(conn,replace(String.trim_all_whites(
			win->buf->get_text(win->buf->get_start_iter(),win->buf->get_end_iter(),0)
		),"\n","\r\n")+"\r\n");
		win->buf->set_modified(0);
	}

	void close_unchanged()
	{
		win->buf->set_modified(0);
		pb_close_click();
	}

	void pb_close_click()
	{
		if (win->buf->get_modified())
		{
			confirm(0,"File has been modified, close without sending/saving?",win->mainwindow,close_unchanged);
			return;
		}
		win->signals=0;
		win->mainwindow->destroy();
	}

	void cursorpos(mixed unknown,object self,object mark,mixed foo)
	{
		if (mark->get_name()!="insert") return;
		GTK2.TextIter iter=win->buf->get_iter_at_mark(mark);
		win->curpos->set_text(iter->get_line()+","+iter->get_line_offset());
	}

	void dosignals()
	{
		::dosignals();
		win->signals+=({
			gtksignal(win->pb_send,"clicked",pb_send_click),
			gtksignal(win->pb_close,"clicked",pb_close_click),
			//NOTE: This currently crashes Pike, due to over-freeing of the top stack object
			//(whatever it is). See the shim in the function definition, which shouldn't be
			//necessary. Am disabling this code until a patch or workaround is deployed.
			//gtksignal(win->buf,"mark_set",cursorpos),
		});
	}
}

int outputhook(string line,mapping(string:mixed) conn)
{
	if (line=="===> Editor <===")
	{
		conn->editor_eax="";
		return 0;
	}
	if (conn->editor_eax)
	{
		if (line=="<=== Editor ===>") {editor(conn,m_delete(conn,"editor_eax")); return 0;}
		conn->editor_eax+=line+"\n";
		return 0;
	}
}
