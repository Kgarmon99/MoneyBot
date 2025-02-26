import { 
  Conversation, 
  InsertConversation, 
  Message, 
  InsertMessage, 
  AIModel 
} from '../shared/schema';

/**
 * Storage interface for application data
 */
export interface IStorage {
  // Conversation methods
  getConversations(): Promise<Conversation[]>;
  getConversation(id: number): Promise<Conversation | undefined>;
  createConversation(conversation: InsertConversation): Promise<Conversation>;
  deleteConversation(id: number): Promise<void>;

  // Message methods
  getMessages(conversationId?: number): Promise<Message[]>;
  getMessage(id: number): Promise<Message | undefined>;
  createMessage(message: InsertMessage): Promise<Message>;

  // AI model methods
  getModels(): Promise<AIModel[]>;
}

/**
 * In-memory storage implementation
 */
export class MemStorage implements IStorage {
  private conversations: Conversation[] = [];
  private messages: Message[] = [];
  private models: AIModel[] = [
    {
      id: "gpt-4o",
      name: "GPT-4o",
      description: "Most advanced model, great for financial advice with stronger reasoning"
    },
    {
      id: "gpt-4-turbo",
      name: "GPT-4 Turbo",
      description: "Enhanced version of GPT-4 with improved performance for financial analysis"
    },
    {
      id: "gpt-3.5-turbo",
      name: "GPT-3.5 Turbo", 
      description: "Fast and cost-effective model for basic financial queries and advice"
    }
  ];

  constructor() {
    // Initialize with some sample data
    // This would be replaced with database fetching in a real app
    const now = new Date();
    this.conversations = [
      {
        id: 1,
        title: "Financial Planning Basics",
        createdAt: now,
        updatedAt: now
      },
      {
        id: 2,
        title: "Investment Strategies",
        createdAt: now,
        updatedAt: now
      }
    ];

    this.messages = [
      {
        id: 1,
        conversationId: 1,
        role: "user",
        content: "How do I start budgeting?",
        createdAt: new Date(),
        model: "gpt-4o"
      },
      {
        id: 2,
        conversationId: 1,
        role: "assistant",
        content: "To start budgeting, first track your income and expenses for a month to understand your spending patterns. Then, create categories for your expenses like housing, food, transportation, and entertainment. Allocate specific amounts to each category based on your income and financial goals. The 50/30/20 rule is a good starting point: 50% for needs, 30% for wants, and 20% for savings and debt repayment. Use budgeting apps like Mint or YNAB to help you stay on track.",
        createdAt: new Date(),
        model: "gpt-4o"
      }
    ];
  }

  async getConversations(): Promise<Conversation[]> {
    return [...this.conversations].sort((a, b) => 
      new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
    );
  }

  async getConversation(id: number): Promise<Conversation | undefined> {
    return this.conversations.find(conv => conv.id === id);
  }

  async createConversation(data: InsertConversation): Promise<Conversation> {
    const id = this.conversations.length > 0 
      ? Math.max(...this.conversations.map(c => c.id)) + 1 
      : 1;
    
    const conversation: Conversation = {
      id,
      title: data.title,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    this.conversations.push(conversation);
    return conversation;
  }

  async deleteConversation(id: number): Promise<void> {
    const index = this.conversations.findIndex(conv => conv.id === id);
    if (index !== -1) {
      this.conversations.splice(index, 1);
      // Also delete associated messages
      this.messages = this.messages.filter(msg => msg.conversationId !== id);
    }
  }

  async getMessages(conversationId?: number): Promise<Message[]> {
    let filteredMessages = [...this.messages];
    
    if (conversationId !== undefined) {
      filteredMessages = filteredMessages.filter(msg => msg.conversationId === conversationId);
    }
    
    return filteredMessages.sort((a, b) => 
      new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
    );
  }

  async getMessage(id: number): Promise<Message | undefined> {
    return this.messages.find(msg => msg.id === id);
  }

  async createMessage(data: InsertMessage): Promise<Message> {
    const id = this.messages.length > 0 
      ? Math.max(...this.messages.map(m => m.id)) + 1 
      : 1;
    
    const message: Message = {
      id,
      conversationId: data.conversationId,
      role: data.role,
      content: data.content,
      createdAt: new Date(),
      model: data.model || 'gpt-4o' // Default to the latest model if not specified
    };
    
    this.messages.push(message);
    
    // Update the conversation's updatedAt timestamp
    const conversation = this.conversations.find(c => c.id === data.conversationId);
    if (conversation) {
      conversation.updatedAt = new Date();
    }
    
    return message;
  }

  async getModels(): Promise<AIModel[]> {
    return [...this.models];
  }
}