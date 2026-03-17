import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Todolist",
  description: "A simple todolist app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
