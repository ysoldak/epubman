package epubman;

import java.io.PrintStream;

import nl.siegmann.epublib.Constants;
import nl.siegmann.epublib.domain.Author;
import nl.siegmann.epublib.domain.Book;
import nl.siegmann.epublib.domain.Identifier;
import nl.siegmann.epublib.epub.EpubReader;
import nl.siegmann.epublib.util.VFSUtil;

public class EpubCli {

	public static void main(String[] args) throws Exception {

		PrintStream out = new PrintStream(System.out, true, "UTF-8");

		String info = (args.length == 1) ? "itaf" : args[0];
		String file = (args.length == 1) ? args[0] : args[1];

		Book book = new EpubReader().readEpub(VFSUtil.resolveInputStream(file), Constants.ENCODING);

		//Book book = new EpubReader().readEpub(VFSUtil.resolveInputStream(file), "");

		if (info.contains("i")) {
			out.println(getAllIdentifiers(book));
		}
		if (info.contains("t")) {
			out.println(book.getTitle());
		}
		if (info.contains("a")) {
			String authors = "";
			for (Author a : book.getMetadata().getAuthors()) {
				//String name = a.getFirstname().trim() + " " + a.getLastname().trim();
				String name = a.getLastname().trim() + ", " + a.getFirstname().trim();
				if (authors.length() != 0) {
					authors += ";";
				}
				authors += name;
			}
			out.println(authors);
		}
		if (info.contains("f")) {
			String id = "";
			for (Identifier i : book.getMetadata().getIdentifiers()) {
				if (i.getValue().length() != 0) {
					id = i.getValue();
					break;
				}
			}
			id = id.replaceAll(":", "_").replaceAll("\\/", "_");
			String newFilename = book.getTitle() + " - " + id + ".epub";
			out.println(newFilename);
		}
	}

//	private static void print(String str) {
//		System.out.println(str);
//	}

	private static String getAllIdentifiers(Book book) {
		String ids = "";
		for (Identifier i : book.getMetadata().getIdentifiers()) {
			if (i.getValue().length() != 0) {
				if (ids.length() != 0) {
					ids += ";";
				}
				ids = i.getValue();
			}
		}
		return ids;
	}

}