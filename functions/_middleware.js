const host = "com-kalaclista-the.pages.dev";

export async function onRequest(context) {
  if (context.request.url.match(host) !== null) {
    return new Response("", {
      status: 308,
      headers: {
        Location: context.request.url.replace(host, "the.kalaclista.com"),
      },
    });
  }

  return await context.next();
}
