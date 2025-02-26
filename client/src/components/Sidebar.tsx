import { Link, useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { Menu, X } from "lucide-react";

interface SidebarProps {
  isOpen: boolean;
  toggleSidebar: () => void;
}

const Sidebar = ({ isOpen, toggleSidebar }: SidebarProps) => {
  const [location] = useLocation();

  const isLinkActive = (path: string) => {
    if (path === '/' && location === '/') return true;
    if (path !== '/' && location.startsWith(path)) return true;
    return false;
  };

  const NavLink = ({ href, children }: { href: string; children: React.ReactNode }) => (
    <Link href={href}>
      <a className={`block px-2 py-1 text-sm rounded hover:bg-white transition-colors ${
        isLinkActive(href) ? 'text-primary font-medium' : 'text-accent hover:text-primary'
      }`}>
        {children}
      </a>
    </Link>
  );

  const NavSection = ({ title, children }: { title: string; children: React.ReactNode }) => (
    <div className="mb-4">
      <h2 className="text-xs font-semibold text-accent uppercase tracking-wider mb-2">{title}</h2>
      <ul className="space-y-1">
        {children}
      </ul>
    </div>
  );

  return (
    <>
      <aside className={`bg-[#F7F7F8] border-r border-[#E5E5E5] ${
        isOpen ? "w-64" : "w-0 overflow-hidden"
      } lg:w-64 h-screen transition-all fixed lg:relative z-20`}>
        <div className="p-4 flex items-center justify-between">
          <div className="flex items-center">
            <div className="h-8 w-8 rounded-md bg-primary flex items-center justify-center text-white mr-2">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M4 2a2 2 0 00-2 2v12a2 2 0 002 2h12a2 2 0 002-2V4a2 2 0 00-2-2H4zm3 3a1 1 0 00-1 1v10a1 1 0 001 1h6a1 1 0 001-1V6a1 1 0 00-1-1H7z" clipRule="evenodd" />
              </svg>
            </div>
            <h1 className="text-lg font-bold text-[#202123]">MoneyBot API</h1>
          </div>
          <Button 
            variant="ghost" 
            size="icon" 
            onClick={toggleSidebar}
            className="lg:hidden"
          >
            <X className="h-5 w-5" />
          </Button>
        </div>
        <Separator />
        <div className="p-4 overflow-y-auto h-[calc(100vh-60px)]">
          <NavSection title="Introduction">
            <li><NavLink href="/#overview">Overview</NavLink></li>
            <li><NavLink href="/#authentication">Authentication</NavLink></li>
            <li><NavLink href="/#errors">Errors</NavLink></li>
          </NavSection>
          
          <NavSection title="Endpoints">
            <li><NavLink href="/#chat-completion">Chat Completion</NavLink></li>
            <li><NavLink href="/#message-history">Message History</NavLink></li>
            <li><NavLink href="/#model-selection">Model Selection</NavLink></li>
          </NavSection>
          
          <NavSection title="iOS Integration">
            <li><NavLink href="/#ios-examples">iOS Examples</NavLink></li>
            <li><NavLink href="/#mobile-optimizations">Mobile Optimizations</NavLink></li>
          </NavSection>
          
          <NavSection title="Resources">
            <li><NavLink href="/playground">API Playground</NavLink></li>
            <li><NavLink href="/#faq">FAQ</NavLink></li>
          </NavSection>
        </div>
      </aside>
      
      {/* Mobile menu button for when sidebar is closed */}
      {!isOpen && (
        <Button 
          variant="ghost" 
          size="icon" 
          onClick={toggleSidebar}
          className="fixed top-4 left-4 z-20 lg:hidden"
        >
          <Menu className="h-5 w-5" />
        </Button>
      )}
      
      {/* Overlay when sidebar is open on mobile */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/30 z-10 lg:hidden"
          onClick={toggleSidebar}
        />
      )}
    </>
  );
};

export default Sidebar;
